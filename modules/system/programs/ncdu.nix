{ self, ... }:
{
  flake.modules.nixos.ncdu =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.ncdu
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.ncdu
    ];
  };
}
