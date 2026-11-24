{
  den.aspects.niri = {
    # TODO we'll need to add more configs for niri once we move to hm 26.11
    nixos = { pkgs, ... }: {
      programs.niri.enable = true;

      # niri auto-spawns xwayland-satellite on demand for X11 clients.
      environment.systemPackages = [ pkgs.xwayland-satellite ];
    };
    provides.to-users = {
      homeManager = { lib, ... }: {
        programs.waybar = {
          settings.main = {
            # niri modules layer after the base waybar config; don't enable
            # the Hyprland aspect at the same time.
            modules-left = lib.mkOrder 102 [
              "niri/workspaces"
              "niri/window"
            ];
          };
          style = lib.mkAfter ''
            * {
              font-size: 16px;
            }
            window#waybar {
              min-height: 24px;
            }
            #workspaces button.active {
              border-bottom: 2px solid #d65d0e;
            }
          '';
        };
        xdg.configFile."niri/config.kdl".source = ./config.kdl;
      };
    };
  };
}
