{
  den.aspects.systemd-boot = efiMountPoint: {
    nixos = {
      boot.loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 8;
        };
        efi = {
          canTouchEfiVariables = true;
          # must match the ESP mountpoint configured in disko
          efiSysMountPoint = efiMountPoint;
        };
      };
    };
  };
}
