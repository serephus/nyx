{ self, ... }:
{
  flake.modules.nixos.xh =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.xh
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.xh
    ];
  };
}
