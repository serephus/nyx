{ self, ... }:
{
  flake.modules.nixos.nix-diff =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.nix-diff
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.nix-diff
    ];
  };
}
