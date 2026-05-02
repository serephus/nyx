{ self, ... }:
{
  flake.modules.nixos.nix-index =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.nix-index
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.nix-index
    ];
  };
}
