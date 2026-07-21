{ self, ... }:
{
  flake.modules.nixos.nh =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.nh
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.nh
    ];
  };
}
