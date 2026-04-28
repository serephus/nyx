{ self, ... }:
{
  flake.modules.homeManager.mako = {
    services.mako.enable = true;
  };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.mako
    ];
  };
}
