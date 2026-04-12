{ self, ... }:
{
  flake.modules.nixos.sudo = {
    # use sudo-rs
    security.sudo.enable = false;
    security.sudo-rs = {
      enable = true;
    };
  };

  flake.modules.nixos.minimal = {
    imports = [ self.modules.nixos.sudo ];
  };
}
