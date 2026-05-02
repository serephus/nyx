{ self, ... }:
{
  flake.modules.nixos.nix-output-monitor =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.nix-output-monitor
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.nix-output-monitor
    ];
  };
}
