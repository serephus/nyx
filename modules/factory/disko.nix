{
  config.flake.factory.disko = device: {
    nixos."${device}" =
      { config, ... }:
      {
        disko.devices.disk.main = {
          type = "disk";
          device = "/dev/${device}";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                priority = 1;
                name = "ESP";
                start = "1M";
                end = "1024M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = config.constants.efiMountpoint;
                  mountOptions = [ "umask=0077" ];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # Override existing partition
                  subvolumes =
                    let
                      mkSubvol = name: {
                        mountpoint = "/${name}";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                    in
                    {
                      "@root" = mkSubvol "";
                      "@home" = mkSubvol "home";
                      "@nix" = mkSubvol "nix";
                      "@var" = mkSubvol "var";
                      "@tmp" = mkSubvol "tmp";
                      # reserved for impermanence
                      "@persist" = mkSubvol "persist";
                      # for snapshots
                      "@snapshot" = mkSubvol ".snapshot";
                      "@swap" = {
                        mountpoint = "/.swapvol";
                        swap.swapfile = {
                          size = "20480M";
                          path = "swapfile";
                        };
                      };
                    };
                };
              };
            };
          };
        };
      };
  };
}
