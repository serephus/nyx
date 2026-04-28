{ self, ... }:
{
  flake.modules.homeManager.copyq = {
    services.copyq = {
      enable = true;
      forceXWayland = false;
    };
  };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.copyq
    ];
  };
}
