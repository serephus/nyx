{ self, ... }:
{
  flake.modules.homeManager.mpv = {
    programs.mpv.enable = true;
  };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.mpv
    ];
  };
}
