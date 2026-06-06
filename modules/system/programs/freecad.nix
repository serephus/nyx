{ self, ... }:
{
  flake.modules.nixos.freecad =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.freecad
      ];
    };

  flake.modules.nixos.desktop = {
    imports = [
      self.modules.nixos.freecad
    ];
  };
}
