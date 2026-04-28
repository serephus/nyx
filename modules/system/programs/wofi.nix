{ self, ... }:
{
  flake.modules.homeManager.wofi =
    { pkgs, lib, ... }:
    {
      programs.wofi.enable = true;
      wayland.windowManager.hyprland.settings."$menu" =
        lib.mkOverride 100 "${lib.getExe pkgs.wofi} --show drun";
    };

  flake.modules.homeManager.hyprland = {
    imports = [
      self.modules.homeManager.wofi
    ];
  };
}
