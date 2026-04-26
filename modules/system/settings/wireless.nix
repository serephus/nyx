{ self, ... }:
{
  flake.modules.nixos.wireless = {
    networking.wireless.enable = true;
  };

  flake.modules.nixos.laptop = {
    imports = [
      self.modules.nixos.wireless
    ];
  };
}
