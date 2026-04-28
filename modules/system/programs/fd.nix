{ self, ... }:
{
  flake.modules.nixos.fd =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.fd
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.fd
    ];
  };
}
