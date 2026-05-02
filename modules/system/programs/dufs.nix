{ self, ... }:
{
  flake.modules.nixos.dufs =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.dufs
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.dufs
    ];
  };
}
