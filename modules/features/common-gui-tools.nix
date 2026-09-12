{
  den.aspects.common-gui-tools = {
    provides.to-users = { user, ... }: {
      nixos = {
        # TODO: this does not preserve chromium state, just configs
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [
              ".config/chromium"
              # stops chromium from requesting keyring creation every launch
              # we don't have any other programs requesting keyring
              # so we just put it here right now
              ".local/share/keyrings"
            ];
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
