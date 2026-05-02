{ self, ... }:
{
  flake.modules.nixos.nix-tree =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.nix-tree
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.nix-tree
    ];
  };
}
