{ self, ... }:
{
  flake.modules.nixos.grex =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.grex
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.grex
    ];
  };
}
