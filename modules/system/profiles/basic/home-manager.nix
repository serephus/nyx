{ self, ... }:
{
  flake.modules.homeManager.basic = {
    imports = [
      self.modules.homeManager.minimal
    ];
  };
}
