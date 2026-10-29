{ den, ... }: {
  # aly host aspect
  den.aspects.aly = {
    includes = [
      # stateless (ephemeral tmpfs root) on a hybrid (SeaBIOS + UEFI) disk;
      # the @root/@nix/@var/@home subvolumes live under /persist
      (den.aspects.rootFileSystem {
        device = "/dev/vda";
        bootPartitions = [
          {
            name = "ESP";
            size = "128M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          }
        ];
        ephemeralRoot = true;
        encrypted = false;
        fido2 = false;
        swapSize = 4;
        tmpfsSize = "1G";
        includeHome = true;
      })
      (den.aspects.systemd-boot "/boot")
      (den.aspects.vaultix "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ91WflJccDAniHDqNp/0ej5P4iCZilYm6rmS1wKV3YB")
      (den.aspects.preservation true)
      den.aspects.root

      # extra nix configs
      den.aspects.nix-mirror-ustc
      den.aspects.clean-flake-registry

      # essential services and programs
      den.aspects.ssh

      # core cli programs
      den.aspects.git
      den.aspects.fish
      den.aspects.helix
      den.aspects.tmux

      den.aspects.frps
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
      services.qemuGuest.enable = true;
    };
  };
}
