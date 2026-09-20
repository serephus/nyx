{
  den.aspects.niri = {
    nixos = { pkgs, ... }: {
      programs.niri.enable = true;

      # niri auto-spawns xwayland-satellite on demand for X11 clients.
      environment.systemPackages = [ pkgs.xwayland-satellite ];
    };
    provides.to-users = {
      homeManager = { lib, ... }: {
        programs.waybar = {
          # we'll need to add more configs for niri once we move to hm 26.11
          settings.main = {
            modules-left = lib.mkOrder 102 [
              "niri/workspaces"
              "niri/window"
            ];
          };
          style = ''
            * {
              font-size: 16px;
            }
            window#waybar {
              min-height: 24px;
            }
          '';
        };
        xdg.configFile."niri/config.kdl".source = ./config.kdl;
      };
    };
  };
}
