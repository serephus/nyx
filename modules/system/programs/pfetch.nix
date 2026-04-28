{ self, ... }:
{
  flake.modules.nixos.pfetch =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.pfetch-rs
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.pfetch
    ];
  };
}
