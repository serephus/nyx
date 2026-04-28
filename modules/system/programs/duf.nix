{ self, ... }:
{
  flake.modules.nixos.duf =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.duf
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.duf
    ];
  };
}
