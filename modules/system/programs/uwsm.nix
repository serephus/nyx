{ self, ... }:
{
  flake.modules.nixos.uwsm = {
    programs.uwsm.enable = true;
  };

  flake.modules.nixos.hyprland = {
    imports = [
      self.modules.nixos.uwsm
    ];
  };
}
