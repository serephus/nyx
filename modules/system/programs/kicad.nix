{ self, ... }:
{
  flake.modules.homeManager.kicad =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.kicad
      ];
    };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.kicad
    ];
  };
}
