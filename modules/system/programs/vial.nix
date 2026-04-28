{ self, ... }:
{
  flake.modules.homeManager.vial =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.vial
      ];
    };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.vial
    ];
  };
}
