{ den, ... }: {
  den.aspects.hyprwm = {
    includes = [
      den.aspects.font
      den.aspects.greet
      den.aspects.hyprland
      den.aspects.wofi
    ];
  };
}
