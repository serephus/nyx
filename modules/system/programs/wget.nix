{ self, ... }:
{
  flake.modules.nixos.wget =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.wget
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.wget
    ];
  };
}
