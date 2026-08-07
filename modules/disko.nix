{ inputs, lib, ... }: {

  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [ inputs.disko.flakeModules.disko ];

  den.aspects = {
    rootFileSystem =
      {
        device,
        stateless ? true,
        encrypted ? true,
      }:
      let
        mkStatedPath =
          stateless: path:
          let
            prefix = if stateless then "/persist" else "/";
          in
          "${prefix}${path}";
        mkPath = mkStatedPath stateless;
        rootPath = mkPath "";
        homePath = mkPath "home";
        varPath = mkPath "var";
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
          enrollFido2 = true;
          # Do not wait for recovery displaying and blocking formatting.
          enrollRecovery = false;
          # interactive password login
          # passwordFile = "/tmp/secret.key";
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
        efiPartition = mkEFI "/boot";
        rawPartition = mkRootPartition stateless;
        rootPartition = {
          size = "100%";
          content = if encrypted then mkLuks rawPartition else rawPartition;
        };
      in
      {
        nixos =
          let
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
