{ self, ... }:
{
  # basic inherit minimal, provide a basic cli system
  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.minimal
    ];
  };
}
