{ self, ... }:
{
  flake.modules.homeManager.obs = {
    programs.obs-studio.enable = true;
  };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.obs
    ];
  };
}
