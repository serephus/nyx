{ inputs, lib, ... }: {
  # TODO: add dataFileSystem

  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # what this does again?
  imports = [ inputs.disko.flakeModules.disko ];

  den.aspects = {
    # create disko configs for root file system
    # support full disk encryption, "stateless" root
    rootFileSystem =
      {
        device,
        stateless ? true,
        encrypted ? true,
        fido2 ? true,
      }:
      let
        rootPath = if stateless then "/persist" else "/";
        homePath = if stateless then "/persist/home" else "/home";
        varPath = if stateless then "/persist/var" else "/var";
        mkSubvol = path: {
          mountpoint = path;
          mountOptions = [
            "compress=zstd"
            "noatime"
          ];
        };
        mkRootPartition = stateless: {
          type = "btrfs";
          extraArgs = [ "-f" ];
          subvolumes = {
            "@root" = mkSubvol rootPath;
            "@nix" = mkSubvol "/nix";
            "@home" = mkSubvol homePath;
            "@var" = mkSubvol varPath;
            "@swap" = {
              mountpoint = "/.swapvol";
              swap.swapfile = {
                size = "20480M";
                path = "swapfile";
              };
            };
          };
        };
        mkLuks = content: {
          type = "luks";
          name = "crypted";
          settings.allowDiscards = true;
          enrollFido2 = fido2;
          # interactive login as fallback
          additionalKeyFiles = [ "/tmp/secret.key" ];
          # Do not wait for recovery displaying and blocking formatting.
          enrollRecovery = false;
          content = content;
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
            # does luks requires mount EFI partition at /boot?
            mountpoint = path;
            mountOptions = [ "umask=0077" ];
          };
        };
      in
      {
        nixos =
          let
            efiPartition = mkEFI "/boot";
            rawPartition = mkRootPartition stateless;
            rootPartition = {
              size = "100%";
              content = if encrypted then mkLuks rawPartition else rawPartition;
            };
            tmpfs_root_dev = lib.optionalAttrs stateless {
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
              disk.main = {
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
          in
          {
            imports = [ inputs.disko.nixosModules.disko ];
            disko.devices = tmpfs_root_dev // disks;
            fileSystems."/nix" = {
              neededForBoot = true;
            };
            fileSystems."${rootPath}" = {
              neededForBoot = true;
            };
            fileSystems."${varPath}" = {
              neededForBoot = true;
              depends = [ "${rootPath}" ];
            };
            fileSystems."${homePath}" = {
              depends = [ "${rootPath}" ];
            };
          };
      };
  };
}
