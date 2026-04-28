{ self, ... }:
{
  flake.modules.nixos.rage =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.rage
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.rage
    ];
  };
}
