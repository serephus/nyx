{ self, ... }:
{
  flake.modules.nixos.bluetooth = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
  };

  flake.modules.nixos.laptop = {
    imports = [
      self.modules.nixos.bluetooth
    ];
  };
}
