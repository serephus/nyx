{ self, ... }:
{
  flake.modules.nixos.nix-du =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.nix-du
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.nix-du
    ];
  };
}
