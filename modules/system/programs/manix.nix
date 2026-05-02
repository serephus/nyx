{ self, ... }:
{
  flake.modules.nixos.manix =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.manix
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.manix
    ];
  };
}
