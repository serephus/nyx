{ den, ... }: {
  # vex host aspect
  den.aspects.vex = {
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
        swapSize = 2;
        tmpfsSize = "128M";
        includeHome = true;
      })
      (den.aspects.systemd-boot "/boot")
      (den.aspects.vaultix "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICnS0tQY6it20pzID6VWtGas1vl4dcCSj/egYP34aV0+")
      (den.aspects.preservation true)
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

      den.aspects.v2server
    ];

    # host NixOS configuration
    nixos = { lib, config, ... }: {
      # timezone
      time.timeZone = "America/New_York";
      documentation = {
        enable = lib.mkForce false;
        nixos.enable = lib.mkForce false;
      };
      services.journald.extraConfig = ''
        Storage=volatile
        RuntimeMaxUse=32M
      '';
      # Use chrony instead of timesyncd for a lighter time sync
      services.timesyncd.enable = false;
      services.chrony.enable = true;
      hardware.enableRedistributableFirmware = false;
      hardware.enableAllFirmware = false;

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
