{ self, ... }:
{
  flake.modules.homeManager.gnuplot =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.gnuplot
      ];
    };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.gnuplot
    ];
  };
}
