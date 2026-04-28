{ self, ... }:
{
  flake.modules.nixos.tokei =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.tokei
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.tokei
    ];
  };
}
