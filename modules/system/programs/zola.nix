{ self, ... }:
{
  flake.modules.nixos.zola =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.zola
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.zola
    ];
  };
}
