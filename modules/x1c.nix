{ den, inputs, ... }: {
  # x1c host aspect
  den.aspects.x1c =
    let
      stateless = true;
      encrypted = true;
      fido2 = false;
    in
    {
      includes = [
        den.batteries.hostname
        (den.aspects.rootFileSystem {
          device = "/dev/sda";
          stateless = stateless;
          encrypted = encrypted;
          fido2 = fido2;
        })
        (den.aspects.vaultix "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXvckmMZo48If0O1qTTnQRjMeiARAp7sfWNDbX8p6Eu")
        (den.aspects.preservation stateless)
        den.aspects.systemd-boot

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
        boot = {
          # hardware related configs
          initrd = {
            systemd.enable = true;
            kernelModules = [ ];
            availableKernelModules = [
              "xhci_pci"
              "ehci_pci"
              "ahci"
              "usb_storage"
              "sd_mod"
              "sdhci_pci"
            ];
            # we don't want to pregenerate the host keys
            # network = {
            #   enable = stateless;
            #   ssh = {
            #     enable = stateless;
            #     authorizedKeys = [
            #       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJCl8X5dDv+19y323NZkCbSMiou8phYjbTvTUou5Ju+w i@sereph.us"
            #     ];
            #   };
            # };
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
      provides.to-users.homeManager = {
        # home manager configs
      };
    };
}
