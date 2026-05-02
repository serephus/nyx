{ self, ... }:
{
  flake.modules.nixos.jid =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.jid
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.jid
    ];
  };
}
