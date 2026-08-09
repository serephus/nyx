{ den, inputs, ... }: {
  # nyx host aspect
  den.aspects.nyx =
    let
      ephemeralRoot = true;
      encrypted = true;
      efiMountPoint = "/boot/efi";
      swapSize = 20;
      fido2 = true;
      secureboot = true;
    in
    {
      includes = [
        # mostly hardware stuff
        den.batteries.hostname
        (den.aspects.rootFileSystem {
          device = "/dev/nvme0n1";
          swapSize = swapSize;
          efiMountPoint = efiMountPoint;
          ephemeralRoot = ephemeralRoot;
          encrypted = encrypted;
          fido2 = fido2;
        })
        (den.aspects.vaultix "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK8KwCDs9Db33i+eDX8yaoafNqwfYDldQa2ZIkio7ph3")
        (den.aspects.preservation ephemeralRoot)
        (den.aspects.lanzaboote secureboot)
        (den.aspects.systemd-boot efiMountPoint)
        den.aspects.firmware
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
        den.aspects.openpgp

        # mostly laptop stuff
        den.aspects.wifi
        den.aspects.libinput
        den.aspects.bluetooth

        den.aspects.hyprwm

        den.aspects.common-gui-tools
        den.aspects.alacritty
        den.aspects.qutebrowser
        den.aspects.telegram
        den.aspects.obs
        den.aspects.blender
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
            #     authorizedKeys = [ <pubkey> ];
            #   };
            # };
          };
          kernelModules = [ "kvm-intel" ];
          extraModulePackages = [ ];
        };
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
    };
}
