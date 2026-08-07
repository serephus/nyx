{ den, ... }: {
  # host aspect
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
        den.aspects.ssh
        den.aspects.doc

        den.aspects.git
        den.aspects.fish
        den.aspects.helix
        den.aspects.tmux

        den.aspects.wifi
      ];

      # host NixOS configuration
      nixos = { pkgs, ... }: {
        # timezone
        time.timeZone = "Asia/Shanghai";
        boot = {
          # let try systemd-boot
          loader = {
            systemd-boot = {
              enable = true;
              configurationLimit = 10;
            };
            efi.canTouchEfiVariables = true;
          };

          # hardware related configs

          initrd = {
            systemd.enable = true;
            availableKernelModules = [
              "xhci_pci"
              "nvme"
              "usbhid"
              "usb_storage"
              "sd_mod"
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
