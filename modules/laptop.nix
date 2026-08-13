{ den, ... }: {
  # laptop host aspect
  den.aspects.laptop =
    {
      disks,
      imports,
      kernelModules,
      hostPubKey,
      efiMountPoint ? "/boot/efi",
      secureboot ? true,
    }:
    {
      includes = disks ++ [
        # mostly hardware stuff
        (den.aspects.vaultix hostPubKey)
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
        (den.aspects.openpgp "DD961903")

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
        den.aspects.freecad
        den.aspects.kicad
      ];

      # host NixOS configuration
      nixos = { lib, config, ... }: {
        imports = imports;

        # timezone
        time.timeZone = "Asia/Shanghai";
        boot = {
          zswap.enable = config.swapDevices != [ ];

          # hardware related configs
          initrd = {
            systemd.enable = true;
            kernelModules = [ ];
            availableKernelModules = kernelModules;
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

        # enable power management for laptop
        services.tlp.enable = true;
      };
    };
}
