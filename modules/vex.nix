{ den, inputs, ... }: {
  # vex host aspect
  den.aspects.vex = {
    includes = [
      {
        nixos = {
          imports = [ inputs.disko.nixosModules.disko ];
          disko.devices.disk.main = {
            type = "disk";
            device = "/dev/vda";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  priority = 1;
                  name = "ESP";
                  start = "1M";
                  end = "128M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                  };
                };
                root =
                  let
                    mkSubvol = path: {
                      mountpoint = path;
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  in
                  {
                    size = "100%";
                    content = {
                      type = "btrfs";
                      extraArgs = [ "-f" ];
                      subvolumes = {
                        "@root" = mkSubvol "/";
                        "@nix" = mkSubvol "/nix";
                        "@var" = mkSubvol "/var";
                        "@home" = mkSubvol "/home";
                        "@swap" = {
                          mountpoint = "/.swapvol";
                          swap.swapfile = {
                            size = "4G";
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
      }
      (den.aspects.vaultix "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0FY+WlY4qMfr3PbRNbUfhX5d3WNB5Jsv+ZO7Qv5ypu")
      (den.aspects.preservation true)
      (den.aspects.systemd-boot "/boot")
      den.aspects.firmware
      den.aspects.root

      # extra nix configs
      den.aspects.clean-flake-registry

      # essential services and programs
      den.aspects.ssh

      # core cli programs
      den.aspects.git
      den.aspects.fish
      den.aspects.helix
      den.aspects.tmux
    ];

    # host NixOS configuration
    nixos = { lib, config, ... }: {
      # timezone
      time.timeZone = "Asia/Shanghai";

      boot = {
        zswap.enable = config.swapDevices != [ ];
        initrd = {
          systemd.enable = true;
          availableKernelModules = [
            "ata_piix"
            "uhci_hcd"
            "virtio_pci"
            "sr_mod"
            "virtio_blk"
          ];
          kernelModules = [ ];
        };
        kernelModules = [ ];
        extraModulePackages = [ ];
      };

      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      virtualisation.hypervGuest.enable = true;
    };
  };
}
