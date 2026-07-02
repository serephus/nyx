{ self, ... }:
{
  flake.modules.nixos.ykman =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.yubikey-manager
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.ykman
    ];
  };
}
