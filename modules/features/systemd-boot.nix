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
          # this has to be align with disko config
          # with luks, it has to be "/boot" right? seems like no
          efiSysMountPoint = efiMountPoint;
        };
      };
    };
  };
}
