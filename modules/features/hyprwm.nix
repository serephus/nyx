{ den, ... }: {
  den.aspects.hyprwm = {
    includes = [
      den.aspects.font
      den.aspects.greet
      den.aspects.hyprland
      den.aspects.wofi
      den.aspects.waybar
      den.aspects.hypridle
      den.aspects.hyprlock
      den.aspects.mako
      den.aspects.pipewire
    ];
  };
}
