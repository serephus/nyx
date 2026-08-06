{ den, ... }: {
  # host aspect
  den.aspects.nyx = {
    includes = [
      den.batteries.hostname
      (den.aspects.mkEncryptedRoot "/dev/nvme0n1")
      (den.aspects.vaultix "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXvckmMZo48If0O1qTTnQRjMeiARAp7sfWNDbX8p6Eu")
      den.aspects.preservation
      den.aspects.ssh
      den.aspects.doc
      den.aspects.wifi
    ];

    # host NixOS configuration
    nixos = { pkgs, ... }: {
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
        initrd.availableKernelModules = [
          "xhci_pci"
          "nvme"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
        kernelModules = [ "kvm-intel" ];
      };
      hardware.cpu.intel.updateMicrocode = true;

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
