{ self, ... }:
{
  flake.modules.nixos.age-plugin-yubikey =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.age-plugin-yubikey
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.age-plugin-yubikey
    ];
  };
}
