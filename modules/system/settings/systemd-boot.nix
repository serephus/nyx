{
  # systemd-boot bootloader, on some host, we can't use this
  flake.modules.nixos.systemd-boot =
    { config, ... }:
    {
      boot.loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };
        efi = {
          canTouchEfiVariables = true;
          # this has to be align with disko config
          efiSysMountPoint = config.constants.efiMountpoint;
        };
      };
    };
}
