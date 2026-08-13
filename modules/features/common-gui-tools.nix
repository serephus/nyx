{
  den.aspects.common-gui-tools = {
    provides.to-users = { user, ... }: {
      nixos = {
        # TODO: this does not preserve chromium state, just configs
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [ ".config/chromium" ];
          };
        };
      };
      homeManager = { pkgs, ... }: {
        programs.zathura.enable = true;
        programs.swayimg.enable = true;
        programs.mpv.enable = true;
        programs.chromium.enable = true;
        home.packages = [
          pkgs.gnuplot
        ];
      };
    };
  };
}
