{ self, ... }:
{
  flake.modules.homeManager.wofi = {
    programs.wofi.enable = true;
  };

  flake.modules.homeManager.hyprland = {
    imports = [
      self.modules.homeManager.wofi
    ];
  };
}
