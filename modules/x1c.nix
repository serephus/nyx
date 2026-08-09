{ den, inputs, ... }: {
  # x1c host aspect
  den.aspects.x1c =
    let
      ephemeralRoot = true;
      encrypted = true;
      fido2 = true;
      secureboot = true;
      swapSize = 10;
      efiMountPoint = "/boot/efi";
    in
    {
      includes = [
        # mostly hardware stuff
        den.batteries.hostname
        (den.aspects.rootFileSystem {
          device = "/dev/sda";
          efiMountPoint = efiMountPoint;
          swapSize = swapSize;
          ephemeralRoot = ephemeralRoot;
          encrypted = encrypted;
          fido2 = fido2;
        })
        (den.aspects.vaultix "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILJqleV+Jw3ZlPxoz3tB4eDuwT3oBbq0lNcbokjgXvuT")
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
          };
          kernelModules = [ "kvm-intel" ];
          extraModulePackages = [ ];
        };

        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
    };
}
