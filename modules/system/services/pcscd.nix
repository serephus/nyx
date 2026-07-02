{ self, ... }:
{
  flake.modules.nixos.pcscd = {
    services.pcscd = {
      enable = true;
    };
  };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.pcscd
    ];
  };
}
