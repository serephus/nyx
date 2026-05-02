{ self, ... }:
{
  flake.modules.nixos.compsize =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.compsize
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.compsize
    ];
  };
}
