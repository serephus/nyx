{ den, inputs, ... }: {
  # nyx host aspect
  den.aspects.nyx =
    let
      stateless = true;
      encrypted = true;
      fido2 = true;
    in
    {
      includes = [
        den.batteries.hostname
        (den.aspects.rootFileSystem {
          device = "/dev/nvme0n1";
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
        # technically nyx is x1c 8th gen, but I think this is okay
        imports = [ inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen ];

        # timezone
        time.timeZone = "Asia/Shanghai";
        boot = {
          # hardware related configs
          initrd = {
            systemd.enable = true;
            kernelModules = [ ];
            availableKernelModules = [
              "xhci_pci"
              "nvme"
              "usbhid"
              "usb_storage"
              "sd_mod"
            ];
            # we don't want to pregenerate the host keys
            # which means we may won't able to decrypt with ssh
            # we would also need config wireless in initrd if we want this
            # since x1c 8th doesn't have internet cable
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
        # enable fwupd to update our firmware
        services.fwupd.enable = true;
      };
    };
}
