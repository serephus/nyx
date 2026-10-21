{
  inputs,
  lib,
  ...
}:
let
  btrfsMountOptions = [
    "compress=zstd"
    "noatime"
  ];

  # Wrap a partition content in LUKS.
  # Either enroll a FIDO2 token, or unlock with a key file (e.g. one provided
  # by nixos-anywhere at install time).
  mkLuks =
    {
      name,
      fido2 ? false,
      keyFile ? "/tmp/secret.key",
      content,
    }:
    {
      type = "luks";
      inherit name;
      settings =
        (lib.optionalAttrs (!fido2) (lib.optionalAttrs (keyFile != null) { inherit keyFile; }))
        // {
          allowDiscards = true;
        };
      enrollFido2 = fido2;
      inherit content;
    };

  # ---------------------------------------------------------------------------
  # Turn a map of btrfs subvolume specs into
  #   { content = <disko btrfs partition content>; fileSystems = <nixos fs>; }
  #
  # Spec:
  #   "@name" = {
  #     mountpoint     ? null;      # null => data-only subvolume (no mount)
  #     mountOptions   ? <default>; # only applied when mountpoint != null
  #     swapfile       ? null;      # { size = "20G"; path = "swapfile"; priority = null; }
  #     neededForBoot  ? false;
  #     depends        ? [ ];
  #     fsType         ? null;
  #     disko          ? { };       # escape hatch into the disko subvolume
  #     fs             ? { };       # escape hatch into fileSystems.<mountpoint>
  #   };
  # ---------------------------------------------------------------------------
  mkBtrfs =
    {
      subvolumes,
      defaultMountOptions ? btrfsMountOptions,
    }:
    let
      toDisko =
        _: s:
        {
          mountpoint = s.mountpoint or null;
        }
        // lib.optionalAttrs ((s.mountpoint or null) != null) {
          mountOptions = s.mountOptions or defaultMountOptions;
        }
        // lib.optionalAttrs (s ? swapfile) { swap.swapfile = s.swapfile; }
        // (s.disko or { });

      toFs =
        _: s:
        lib.optional ((s.mountpoint or null) != null) {
          name = s.mountpoint;
          value =
            lib.optionalAttrs (s.neededForBoot or false) { neededForBoot = true; }
            // lib.optionalAttrs ((s.depends or [ ]) != [ ]) { inherit (s) depends; }
            // lib.optionalAttrs (s ? fsType) { inherit (s) fsType; }
            // (s.fs or { });
        };
    in
    {
      content = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        subvolumes = lib.mapAttrs toDisko subvolumes;
      };
      fileSystems = lib.listToAttrs (lib.concatLists (lib.mapAttrsToList toFs subvolumes));
    };

  # ---------------------------------------------------------------------------
  # A single GPT disk:
  #   <boot partitions> <extra partitions> <main partition>
  #
  # `bootPartitions` and `extraPartitions` are ordered lists of disko
  # partition attrsets (each requires `name`). The main partition is always
  # appended last. Priorities are assigned from list position; a `priority`
  # set on an entry is ignored so the list order is authoritative.
  # ---------------------------------------------------------------------------
  mkDisk =
    {
      device,
      name ? "main",
      bootPartitions ? [ ],
      subvolumes ? { },
      defaultMountOptions ? btrfsMountOptions,
      encrypted ? false,
      fido2 ? false,
      keyFile ? "/tmp/secret.key",
      luksName ? "crypted-${name}",
      # swap sugar: inject a btrfs swapfile subvolume
      swap ? false,
      swapSize ? 20,
      swapSubvol ? "@swap",
      swapPath ? "swapfile",
      swapMountpoint ? "/.swapvol",
      swapPriority ? null,
      # escape hatches
      content ? null, # replace the whole main partition content
      extraDevices ? { }, # e.g. nodev."/" = tmpfs
      extraPartitions ? [ ],
      extraSubvolumes ? { },
      extraFileSystems ? { },
    }:
    let
      allSubvolumes =
        subvolumes
        // lib.optionalAttrs swap {
          "${swapSubvol}" = {
            mountpoint = swapMountpoint;
            mountOptions = [ "defaults" ];
            swapfile = {
              size = "${lib.toString swapSize}G";
              path = swapPath;
            }
            // lib.optionalAttrs (swapPriority != null) { priority = swapPriority; };
          };
        }
        // extraSubvolumes;

      btrfs = mkBtrfs {
        subvolumes = allSubvolumes;
        inherit defaultMountOptions;
      };

      mainContent =
        if content != null then
          content
        else if encrypted then
          mkLuks {
            name = luksName;
            inherit fido2 keyFile;
            content = btrfs.content;
          }
        else
          btrfs.content;

      # The main partition is appended after every boot/extra partition, so it
      # always comes last. Priorities are derived from the final list order.
      mainPartition = lib.optional (allSubvolumes != { } || content != null) {
        name = "root";
        size = "100%";
        content = mainContent;
      };

      mkPartitions =
        parts:
        lib.listToAttrs (
          lib.imap0 (
            i: p: lib.nameValuePair p.name ({ priority = 100 + i; } // builtins.removeAttrs p [ "priority" ])
          ) parts
        );

      partitions = mkPartitions (bootPartitions ++ extraPartitions ++ mainPartition);
    in
    {
      nixos = {
        imports = [ inputs.disko.nixosModules.disko ];
        disko.devices = {
          disk."${name}" = {
            type = "disk";
            inherit device;
            content = {
              type = "gpt";
              inherit partitions;
            };
          };
        }
        // extraDevices;
        fileSystems = btrfs.fileSystems // extraFileSystems;
      };
    };

  # ---------------------------------------------------------------------------
  # Presets
  # ---------------------------------------------------------------------------

  # Default root-disk boot layout: a single ESP at /boot/efi. Hosts with a
  # different boot layout (U-Boot, SeaBIOS, tiny /boot, ...) pass their own
  # `bootPartitions` list.
  defaultBootPartitions = [
    {
      name = "ESP";
      size = "1024M";
      type = "EF00";
      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot/efi";
        mountOptions = [ "umask=0077" ];
      };
    }
  ];

  # Ephemeral (or persistent) root with the classic @root/@nix/@var/@home/@swap
  # layout. Old interface kept intact.
  rootFileSystem =
    {
      device,
      name ? "main",
      bootPartitions ? defaultBootPartitions,
      extraPartitions ? [ ],
      ephemeralRoot ? true,
      encrypted ? true,
      fido2 ? true,
      keyFile ? "/tmp/secret.key",
      swapSize ? 20,
      tmpfsSize ? "4G",
      includeHome ? true,
    }:
    let
      persist = "/persist";
      rootPath = if ephemeralRoot then persist else "/";
      varPath = if ephemeralRoot then "${persist}/var" else "/var";
      homePath = if ephemeralRoot then "${persist}/home" else "/home";
    in
    {
      includes = [
        (mkDisk {
          inherit
            device
            name
            bootPartitions
            extraPartitions
            encrypted
            fido2
            keyFile
            swapSize
            ;
          swap = true;
          luksName = "crypted"; # keep existing mapper name
          subvolumes = {
            "@root" = {
              mountpoint = rootPath;
              neededForBoot = true;
            };
            "@nix" = {
              mountpoint = "/nix";
              neededForBoot = true;
            };
            "@var" = {
              mountpoint = varPath;
              neededForBoot = true;
              depends = [ rootPath ];
            };
          }
          // lib.optionalAttrs includeHome {
            "@home" = {
              mountpoint = homePath;
              depends = [ rootPath ];
            };
          };
          extraDevices = lib.optionalAttrs ephemeralRoot {
            nodev."/" = {
              fsType = "tmpfs";
              mountOptions = [
                "defaults"
                "size=${tmpfsSize}"
                "mode=755"
                "noatime"
                "nosuid"
                "nodev"
              ];
            };
          };
        })
      ];
    };

  # A separate btrfs home disk.
  homeFileSystem =
    {
      name ? "home",
      device,
      mountpoint ? "/home",
      rootPath ? "/",
      encrypted ? true,
      fido2 ? true,
    }:
    {
      includes = [
        (mkDisk {
          inherit
            name
            device
            encrypted
            fido2
            ;
          luksName = "crypted-home";
          subvolumes = {
            "@home" = {
              inherit mountpoint;
              depends = [ rootPath ];
            };
          };
        })
      ];
    };

  # A separate btrfs data disk.
  dataFileSystem =
    {
      name ? "data",
      device,
      mountpoint ? "/data",
      encrypted ? true,
      fido2 ? true,
    }:
    {
      includes = [
        (mkDisk {
          inherit
            name
            device
            encrypted
            fido2
            ;
          luksName = "crypted-data";
          subvolumes = {
            "@data" = {
              inherit mountpoint;
            };
          };
        })
      ];
      # let just make it global readable and writable for now
      nixos.systemd.tmpfiles.rules = [ "d ${mountpoint} 0777 root root - -" ];
    };
in
{
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # adds the flake.diskoConfigurations output
  imports = [ inputs.disko.flakeModules.disko ];

  den.aspects = {
    # presets (thin wrappers over `disk`)
    inherit rootFileSystem homeFileSystem dataFileSystem;
  };
}
