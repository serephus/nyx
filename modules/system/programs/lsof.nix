{ self, ... }:
{
  flake.modules.nixos.lsof =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.lsof
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.lsof
    ];
  };
}
