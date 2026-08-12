{
  den.aspects.wofi = {
    provides.to-users.homeManager = { pkgs, lib, ... }: {
      programs.wofi.enable = true;
      wayland.windowManager.hyprland.settings."$menu" =
        lib.mkOverride 100 "${lib.getExe pkgs.wofi} --show drun";
    };
  };
}
