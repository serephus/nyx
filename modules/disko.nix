{ inputs, ... }:
{

  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [ inputs.disko.flakeModules.disko ];

  den.aspects =
    let
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
      mkBtrfsSubvol = path: {
        mountpoint = path;
        mountOptions = [
          "compress=zstd"
          "noatime"
        ];
      };
      btrfsPartition = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        subvolumes = {
          "@nix" = mkBtrfsSubvol "/nix";
          "@persist" = mkBtrfsSubvol "/persist";
          "@home" = mkBtrfsSubvol "/persist/home";
          "@var" = mkBtrfsSubvol "/persist/var";
          "@swap" = {
            mountpoint = "/.swapvol";
            swap.swapfile = {
              size = "20480M";
              path = "swapfile";
            };
          };
        };
      };
      luks = {
        type = "luks";
        name = "crypted";
        settings.allowDiscards = true;
        # enrollFido2 = true;
        # Do not wait for recovery displaying and blocking formatting.
        enrollRecovery = false;
        # interactive password login
        # passwordFile = "/tmp/secret.key";
        content = btrfsPartition;
      };
      mkPersist = content: device: {
        nixos = {
          imports = [
            inputs.disko.nixosModules.disko
          ];
          disko.devices = {
            disk.main = {
              type = "disk";
              device = device;
              content = {
                type = "gpt";
                partitions = {
                  ESP = mkEFI "/boot";
                  root = {
                    size = "100%";
                    content = content;
                  };
                };
              };
            };
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
          fileSystems."/nix" = {
            neededForBoot = true;
          };
          fileSystems."/persist" = {
            neededForBoot = true;
          };
          fileSystems."/persist/var" = {
            neededForBoot = true;
            depends = [ "/persist" ];
          };
          fileSystems."/persist/home" = {
            depends = [ "/persist" ];
          };
        };
      };
    in
    {
      mkRoot = mkPersist btrfsPartition;
      mkEncryptedRoot = mkPersist luks;
    };
}
