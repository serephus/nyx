{
  den.aspects.fuzzel = {
    provides.to-users.homeManager = { pkgs, lib, ... }: {
      programs.fuzzel.enable = true;
      wayland.windowManager.hyprland.settings."$menu" =
        lib.mkOverride 99 "${lib.getExe pkgs.fuzzel} --show drun";
    };
  };
}
