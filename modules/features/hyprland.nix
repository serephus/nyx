{
  den.aspects.hyprland = {
    nixos = {
      programs = {
        hyprland = {
          enable = true;
          withUWSM = false;
          xwayland.enable = false;
        };
      };
    };

    provides.to-users.homeManager =
      { pkgs, lib, ... }:
      let
        numWorkspaces = 9;
      in
      {
        wayland.windowManager.hyprland = {
          enable = true;
          systemd = {
            enable = true;
            variables = [ "--all" ];
          };
          configType = "hyprlang";
          settings = {
            monitor = [
              # ",preferred,auto,auto"
              "eDP-1, 2560x1440@60, 2560x0, auto"
              "HDMI-A-1, 2560x1440@60, 0x0, auto"
            ];

            # we use windows key as mod key
            "$mod" = "SUPER";

            # laptop keyboard, we want norman layout
            device = {
              name = "at-translated-set-2-keyboard";
              kb_layout = "us";
              kb_variant = "norman";
              kb_options = "ctrl:swapcaps";
              resolve_binds_by_sym = "1";
            };

            env = [
              "XCURSOR_SIZE,24"
              "HYPRCURSOR_SIZE,24"
            ];

            general = {
              gaps_in = 2;
              gaps_out = 4;
              border_size = 2;
              layout = "master";
            };

            decoration = {
              rounding = 2;
              inactive_opacity = 0.94;
              active_opacity = 1.0;
            };

            master = {
              mfact = 0.45;
              new_status = "master";
              orientation = "right";
            };

            animations.enabled = true;

            # let try turn off xwayland support
            xwayland.enabled = false;

            # Mod          = focus / open
            # Mod+Shift    = move / close / quit
            # Mod+Ctrl     = move the focused window/column
            # Mod+Shift+Ctrl = send the focused thing to another monitor
            bind = [
              # applications & session
              "$mod, Return, exec, $terminal"
              "$mod, D, exec, $menu"
              "$mod, Q, killactive"
              "$mod, L, exec, hyprlock"
              # hyprshot saves to ~/res/images/screenshots and copies to the
              # clipboard (timestamped filenames, no spaces).
              "$mod, S, exec, ${lib.getExe pkgs.hyprshot} -m region -o ~/res/images/screenshots"
              "$mod SHIFT, S, exec, ${lib.getExe pkgs.hyprshot} -m output -m active -o ~/res/images/screenshots"
              "$mod SHIFT, E, exit"

              # scratchpad / magic workspace (heavily used)
              "$mod, M, togglespecialworkspace, magic"
              "$mod SHIFT, M, movetoworkspace, special:magic"

              # focus (master layout)
              "$mod, left, layoutmsg, cycleprev"
              "$mod, up, layoutmsg, cycleprev"
              "$mod, right, layoutmsg, cyclenext"
              "$mod, down, layoutmsg, cyclenext"
              "$mod, Home, layoutmsg, focusmaster"

              # move / swap windows
              "$mod CTRL, left, layoutmsg, swapprev"
              "$mod CTRL, up, layoutmsg, swapprev"
              "$mod CTRL, right, layoutmsg, swapnext"
              "$mod CTRL, down, layoutmsg, swapnext"
              "$mod CTRL, Home, layoutmsg, swapwithmaster"

              # monitors
              "$mod SHIFT, left, focusmonitor, l"
              "$mod SHIFT, up, focusmonitor, u"
              "$mod SHIFT, right, focusmonitor, r"
              "$mod SHIFT, down, focusmonitor, d"
              "$mod SHIFT CTRL, left, movecurrentworkspacetomonitor, l"
              "$mod SHIFT CTRL, right, movecurrentworkspacetomonitor, r"

              # workspaces
              "$mod, tab, workspace, previous"
              "$mod, Page_Down, workspace, e+1"
              "$mod, Page_Up, workspace, e-1"

              # layout & sizing
              "$mod, F, fullscreen"
              "$mod SHIFT, F, fullscreen, 1"
              "$mod, space, togglefloating"
              "$mod, P, pseudo"
              "$mod, R, layoutmsg, orientationright"
              "$mod SHIFT, R, layoutmsg, orientationleft"
              "$mod, minus, layoutmsg, mfact -0.05"
              "$mod, equal, layoutmsg, mfact +0.05"
            ]
            ++ (
              # workspaces: $mod + N focuses workspace N,
              # $mod + SHIFT + N moves the focused window to workspace N
              let
                mkWorkspaceRule =
                  idx:
                  let
                    ws = toString (idx + 1);
                  in
                  [
                    "$mod, ${ws}, workspace, ${ws}"
                    "$mod SHIFT, ${ws}, movetoworkspace, ${ws}"
                  ];
              in
              builtins.concatLists (builtins.genList mkWorkspaceRule numWorkspaces)
            );
          };
        };

        programs.waybar.settings.main = {
          modules-left = lib.mkOrder 101 [
            "hyprland/workspaces"
            "hyprland/window"
          ];

          "hyprland/workspaces" = {
            # we want every workspace show on every outputs
            persistent-workspaces = builtins.listToAttrs (
              builtins.genList (idx: {
                name = toString (idx + 1);
                value = [ ];
              }) numWorkspaces
            );
            all-outputs = true;
          };
        };
      };
  };
}
