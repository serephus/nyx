{ den, inputs, ... }: {
  # host aspect
  den.aspects.x1c = {
    includes = [
      den.batteries.hostname
      (den.aspects.rootFileSystem { device = "/dev/sda"; })
      (den.aspects.vaultix "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXvckmMZo48If0O1qTTnQRjMeiARAp7sfWNDbX8p6Eu")
      den.aspects.preservation
      den.aspects.ssh
      den.aspects.doc

      den.aspects.git
      den.aspects.fish
      den.aspects.helix
      den.aspects.tmux

      den.aspects.wifi
    ];

    # host NixOS configuration
    nixos = { lib, config, ... }: {
      imports = [
        inputs.nixos-hardware.nixosModules.common-cpu-intel
        inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
      ];

      # timezone
      time.timeZone = "Asia/Shanghai";

      # let try systemd-boot
      boot.loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };
        efi = {
          canTouchEfiVariables = true;
        };
      };

      # hardware related configs
      boot = {
        initrd = {
          systemd.enable = true;
          availableKernelModules = [
            "xhci_pci"
            "ehci_pci"
            "ahci"
            "usb_storage"
            "sd_mod"
            "sdhci_pci"
          ];
          kernelModules = [ ];
        };
        kernelModules = [ "kvm-intel" ];
        extraModulePackages = [ ];
      };

      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      # firmware
      hardware.enableRedistributableFirmware = true;
      services.fwupd.enable = true;
    };

    # host provides default home environment for its users
    provides.to-users.homeManager = { pkgs, ... }: {
      # home manager configs
    };
  };
}
