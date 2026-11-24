{ den, ... }: {
  # laptop host aspect
  den.aspects.laptop =
    {
      extraIncludes,
      hardwareImports,
      kernelModules,
      hostPubKey,
      cpu ? "intel",
      timeZone ? "Asia/Shanghai",
      efiMountPoint ? "/boot/efi",
      secureboot ? true,
    }:
    {
      includes = extraIncludes ++ [
        # mostly hardware stuff
        (den.aspects.vaultix hostPubKey)
        (den.aspects.lanzaboote secureboot)
        (den.aspects.systemd-boot efiMountPoint)
        den.aspects.firmware
        den.aspects.root
        den.aspects.kernel-parameter

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
        den.aspects.cargo

        # credential stuff
        den.aspects.yubikey
        (den.aspects.openpgp "DD961903")
        den.aspects.mihomo

        # mostly laptop stuff
        den.aspects.wifi
        den.aspects.libinput
        den.aspects.bluetooth
        den.aspects.logind

        den.aspects.hyprwm
        den.aspects.niri

        den.aspects.common-gui-tools
        den.aspects.alacritty
        den.aspects.qutebrowser

        # ai related stuff
        den.aspects.pi-coding-agent
        den.aspects.opencode
      ];

      # host NixOS configuration
      nixos = { lib, config, ... }: {
        imports = hardwareImports;

        # timezone
        time.timeZone = timeZone;
        boot = {
          zswap = {
            # this condition here fix the check of the vm packages
            # I think some vm specific option forces empty the swap devices.
            enable = config.swapDevices != [ ];
            maxPoolPercent = 50;
          };

          # hardware related configs
          initrd = {
            systemd.enable = true;
            availableKernelModules = kernelModules;
            # We intentionally don't enable initrd SSH: with an ephemeral root
            # there are no pre-generated host keys, and these machines would
            # also need wireless networking in initrd.
          };
          kernelModules = [ "kvm-${cpu}" ];
        };
        hardware.cpu.${cpu}.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

        # enable power management for laptop
        services.tlp.enable = true;
      };
    };
}
