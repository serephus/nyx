{ inputs, lib, ... }:
let
  btrfsMountOptions = [
    "compress=zstd"
    "noatime"
  ];
  mkLuks =
    {
      name,
      fido2,
      content,
    }:
    let
      passwd = lib.optionalAttrs (!fido2) { keyFile = "/tmp/secret.key"; };
      allowDiscards = {
        allowDiscards = true;
      };
    in
    {
      type = "luks";
      inherit name;
      # TODO: failed to make both yubikey & password works in disko
      # let just stick to either yubikey or password for now
      settings = passwd // allowDiscards;
      enrollFido2 = fido2;
      # Do not wait for recovery displaying and blocking formatting.
      # enrollRecovery = false;
      content = content;
    };
in
{
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # adds the flake.diskoConfigurations output (unused here — disko is wired in via nixosModules.disko below)
  imports = [ inputs.disko.flakeModules.disko ];

  den.aspects = {
    # create disko configs for root file system
    # support full disk encryption, ephemeral root, etc
    rootFileSystem =
      {
        name ? "main",
        device,
        efiMountPoint ? "/boot/efi",
        ephemeralRoot ? true,
        encrypted ? true,
        fido2 ? true,
        swapSize ? 20,
        includeHome ? true,
      }:
      let
        rootPath = if ephemeralRoot then "/persist" else "/";
        homePath = if ephemeralRoot then "/persist/home" else "/home";
        varPath = if ephemeralRoot then "/persist/var" else "/var";
        mkSubvol = path: {
          mountpoint = path;
          mountOptions = btrfsMountOptions;
        };
        subvols = {
          "@root" = mkSubvol rootPath;
          "@nix" = mkSubvol "/nix";
          "@var" = mkSubvol varPath;
          "@swap" = {
            mountpoint = "/.swapvol";
            swap.swapfile = {
              size = "${lib.toString swapSize}G";
              path = "swapfile";
            };
          };
        };
        homeSubvols = lib.optionalAttrs includeHome {
          "@home" = mkSubvol homePath;
        };
        rootPartitionConfig = {
          type = "btrfs";
          extraArgs = [ "-f" ];
          subvolumes = subvols // homeSubvols;
        };
        mkEFI = path: {
          priority = 1;
          name = "ESP";
          start = "1M";
          end = "1024M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            # does luks requires mount EFI partition at /boot? seems like no
            mountpoint = path;
            mountOptions = [ "umask=0077" ];
          };
        };
      in
      {
        nixos =
          let
            efiPartition = mkEFI efiMountPoint;
            rawPartition = rootPartitionConfig;
            rootPartition = {
              size = "100%";
              content =
                if encrypted then
                  mkLuks {
                    name = "crypted";
                    inherit fido2;
                    content = rawPartition;
                  }
                else
                  rawPartition;
            };
            tmpfsRootDev = lib.optionalAttrs ephemeralRoot {
              nodev."/" = {
                fsType = "tmpfs";
                mountOptions = [
                  "defaults"
                  "mode=755"
                  "noatime"
                  "nosuid"
                  "nodev"
                ];
              };
            };
            disks = {
              disk."${name}" = {
                type = "disk";
                device = device;
                content = {
                  type = "gpt";
                  partitions = {
                    ESP = efiPartition;
                    root = rootPartition;
                  };
                };
              };
            };
            fileSystems = {
              "/nix" = {
                neededForBoot = true;
              };
              "${rootPath}" = {
                neededForBoot = true;
              };
              "${varPath}" = {
                neededForBoot = true;
                depends = [ "${rootPath}" ];
              };
            };
            homeFileSystems = lib.optionalAttrs includeHome {
              "${homePath}" = {
                depends = [ "${rootPath}" ];
              };
            };
          in
          {
            imports = [ inputs.disko.nixosModules.disko ];
            disko.devices = tmpfsRootDev // disks;
            fileSystems = fileSystems // homeFileSystems;
          };
      };

    # create a simple btrfs home disk
    homeFileSystem =
      {
        name ? "home",
        device,
        mountpoint ? "/home",
        rootPath ? "/",
        encrypted ? true,
        fido2 ? true,
      }:
      let
        rawPartition = {
          type = "btrfs";
          extraArgs = [ "-f" ];
          subvolumes = {
            "@home" = {
              mountpoint = mountpoint;
              mountOptions = btrfsMountOptions;
            };
          };
        };
      in
      {
        nixos = {
          imports = [ inputs.disko.nixosModules.disko ];
          disko.devices.disk."${name}" = {
            type = "disk";
            device = device;
            content = {
              type = "gpt";
              partitions.home = {
                size = "100%";
                content =
                  if encrypted then
                    mkLuks {
                      name = "crypted-home";
                      inherit fido2;
                      content = rawPartition;
                    }
                  else
                    rawPartition;
              };
            };
          };
          fileSystems."${mountpoint}".depends = [ "${rootPath}" ];
        };
      };

    # create a simple btrfs data disk
    dataFileSystem =
      {
        name ? "data",
        device,
        mountpoint ? "/data",
        encrypted ? true,
        fido2 ? true,
      }:
      let
        rawPartition = {
          type = "btrfs";
          extraArgs = [ "-f" ];
          subvolumes = {
            "@data" = {
              mountpoint = mountpoint;
              mountOptions = btrfsMountOptions;
            };
          };
        };
      in
      {
        nixos = {
          imports = [ inputs.disko.nixosModules.disko ];
          # let just make it global readable and writable for now
          systemd.tmpfiles.rules = [ "d ${mountpoint} 0777 root root - -" ];
          disko.devices.disk."${name}" = {
            type = "disk";
            device = device;
            content = {
              type = "gpt";
              partitions.data = {
                size = "100%";
                content =
                  if encrypted then
                    mkLuks {
                      name = "crypted-data";
                      inherit fido2;
                      content = rawPartition;
                    }
                  else
                    rawPartition;
              };
            };
          };
        };
      };
  };
}
