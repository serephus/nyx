{
  den.aspects.fuzzel = {
    provides.to-users.homeManager = { pkgs, lib, ... }: {
      programs.fuzzel.enable = true;
      # only used when the Hyprland aspect is enabled; the niri config
      # spawns fuzzel directly.
      wayland.windowManager.hyprland.settings."$menu" =
        lib.mkOverride 99 "${lib.getExe pkgs.fuzzel} --show drun";
    };
  };
}
