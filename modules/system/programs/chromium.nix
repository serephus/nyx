{ self, ... }:
{
  flake.modules.homeManager.chromium = {
    programs.chromium.enable = true;
  };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.chromium
    ];
  };
}
