{ den, inputs, ... }: {
  # desk host aspect
  den.aspects.nova =
    let
      # without video output, we can't modify BIOS settings
      # and I'm too lazy to setup secure boot, ssh unlock, etc
      ephemeralRoot = true;
      efiMountPoint = "/boot/efi";
      swapSize = 20;
      encrypted = false;
      fido2 = false;
      secureboot = false;
    in
    {
      includes = [
        # mostly hardware stuff
        (den.aspects.rootFileSystem {
          device = "/dev/nvme0n1";
          swapSize = swapSize;
          efiMountPoint = efiMountPoint;
          ephemeralRoot = ephemeralRoot;
          encrypted = encrypted;
          fido2 = fido2;
        })
        (den.aspects.dataFileSystem {
          device = "/dev/sda";
          mountpoint = "/data";
          encrypted = encrypted;
          fido2 = fido2;
        })
        (den.aspects.vaultix "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBg5IuJhTwtFCQr1F0+ffDtVQqPJcvOeEP/VQ/C/zrLu")
        (den.aspects.preservation ephemeralRoot)
        (den.aspects.lanzaboote secureboot)
        (den.aspects.systemd-boot efiMountPoint)
        den.aspects.firmware
        den.aspects.nvidia
        den.aspects.root

        # extra nix configs
        den.aspects.nix-mirror-ustc
        den.aspects.clean-flake-registry

        # essential services and programs
        den.aspects.ssh
        den.aspects.doc

        # core cli programs
        den.aspects.git
        den.aspects.fish
        den.aspects.helix
        den.aspects.tmux

        # common cli utils
        den.aspects.common-cli-tools
        den.aspects.difftastic
        den.aspects.yazi
        den.aspects.tealdeer
        den.aspects.eza
        den.aspects.direnv

        # credential stuff
        den.aspects.yubikey
        (den.aspects.openpgp "DD961903")
        den.aspects.mihomo
      ];

      # host NixOS configuration
      nixos = { lib, config, ... }: {
        imports = [
          inputs.nixos-hardware.nixosModules.common-cpu-amd
          inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
          inputs.nixos-hardware.nixosModules.common-pc-ssd
        ];

        # timezone
        time.timeZone = "Asia/Shanghai";

        boot = {
          zswap.enable = true;
          initrd = {
            systemd.enable = true;
            availableKernelModules = [
              "xhci_pci"
              "ahci"
              "nvme"
              "usb_storage"
              "usbhid"
              "sd_mod"
            ];
            kernelModules = [ ];
          };
          kernelModules = [ "nvidia" ];
          extraModulePackages = [ ];
        };

        services.xserver = {
          # we don't know if this is necessary, but let enable it for now
          enable = true;
          videoDrivers = [ "nvidia" ];
        };
        hardware = {
          graphics.enable = true;
          cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
          nvidia = {
            open = false;
            modesetting.enable = true;
            nvidiaSettings = false;
            # tesla P40 requires legacy 580.xx driver
            package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
          };
        };
      };
    };
}
