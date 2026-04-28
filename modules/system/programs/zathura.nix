{ self, ... }:
{
  flake.modules.homeManager.zathura = {
    programs.zathura.enable = true;
  };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.zathura
    ];
  };
}
