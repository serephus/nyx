{ self, ... }:
{
  flake.modules.nixos.hgrep =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.hgrep
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.hgrep
    ];
  };
}
