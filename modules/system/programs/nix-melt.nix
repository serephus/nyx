{ self, ... }:
{
  flake.modules.nixos.nix-melt =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.nix-melt
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.nix-melt
    ];
  };
}
