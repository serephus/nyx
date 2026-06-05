{ self, ... }:
{
  flake.modules.nixos.firewall = {
    networking.firewall.enable = false;
  };

  flake.modules.nixos.minimal = {
    imports = [ self.modules.nixos.firewall ];
  };
}
