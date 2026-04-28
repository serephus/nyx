{ self, ... }:
{
  flake.modules.homeManager.swayimg = {
    programs.swayimg.enable = true;
  };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.swayimg
    ];
  };
}
