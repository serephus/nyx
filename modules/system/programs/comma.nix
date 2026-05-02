{ self, ... }:
{
  flake.modules.nixos.comma =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.comma
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.comma
    ];
  };
}
