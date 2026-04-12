{ self, ... }:
{
  flake.modules.nixos.firmware = {
    # fwupd services to update firmware
    services.fwupd.enable = true;
    hardware.enableRedistributableFirmware = true;
  };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.firmware
    ];
  };
}
