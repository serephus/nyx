{ self, ... }:
{
  flake.modules.homeManager.telegram =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.telegram-desktop
      ];
    };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.telegram
    ];
  };
}
