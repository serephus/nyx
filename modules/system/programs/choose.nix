{ self, ... }:
{
  flake.modules.nixos.choose =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.choose
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.choose
    ];
  };
}
