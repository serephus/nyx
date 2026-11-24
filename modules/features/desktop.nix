{ den, ... }: {
  # Wayland desktop application bundle. Hyprland itself is intentionally not
  # included (it stays available in modules/features/hyprland.nix); niri is the
  # active compositor.
  den.aspects.desktop = {
    includes = [
      den.aspects.font
      den.aspects.greet
      den.aspects.fuzzel
      den.aspects.waybar
      den.aspects.hypridle
      den.aspects.hyprlock
      den.aspects.mako
      den.aspects.pipewire
      den.aspects.wpaperd
      den.aspects.clipcat
      den.aspects.bibata
      den.aspects.fcitx5
    ];
  };
}
