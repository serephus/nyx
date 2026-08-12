{
  den.aspects.common-gui-tools = {
    provides.to-users.homeManager = { pkgs, ... }: {
      programs.zathura.enable = true;
      programs.swayimg.enable = true;
      programs.mpv.enable = true;
      # TODO: preserve chromium config
      programs.chromium.enable = true;
      home.packages = [
        pkgs.gnuplot
      ];
    };
  };
}
