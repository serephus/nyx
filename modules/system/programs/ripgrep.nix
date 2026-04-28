{ self, ... }:
{
  flake.modules.nixos.ripgrep =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.ripgrep
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.ripgrep
    ];
  };
}
