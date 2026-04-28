{ self, ... }:
{
  flake.modules.nixos.hexyl =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.hexyl
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.hexyl
    ];
  };
}
