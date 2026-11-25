{
  den.aspects.waybar = {
    provides.to-users.homeManager = { lib, osConfig, ... }: {
      programs.waybar = {
        enable = true;
        systemd.enable = true;
        settings.main = {
          position = "bottom";

          modules-left = lib.mkOrder 100 [ "clock" ];

          modules-right = lib.mkOrder 10000 [
            "network"
            "cpu"
            "memory"
            "battery"
            "tray"
          ];

          clock = {
            interval = 1;
            format = "{:%r %a %b %d}";
            # enable calendar tooltip
            tooltip = true;
            tooltip-format = "<tt>{calendar}</tt>";
            timezone = osConfig.time.timeZone;
          };

          network = {
            format-disconnected = "󰯡";
            format-wifi = "󰖩 {essid}";
            interval = 1;
          };

          cpu = {
            interval = 1;
            format = "󰻠 {usage:02}%";
            states.warning = 95;
          };

          memory = {
            interval = 1;
            format = "󰍛 {percentage:02}%";
            states.warning = 85;
          };

          battery = {
            interval = 10;
            full-at = 99;
            states = {
              "good" = 90;
              "warning" = 30;
              "critical" = 15;
            };
            format = "{icon}  {capacity}%";
            format-charging = "󱐋  {capacity}%";
            format-plugged = "  {capacity}%";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
          };

          tray = {
            icon-size = 14;
            show-passive-items = true;
            spacing = 5;
          };
        };

        style = ''
          * {
            border: none;
            border-radius: 0;
            font-family: FontAwesome, Roboto, Helvetica, Arial, sans-serif;
            font-size: 14px;
            min-height: 0;
          }
          window#waybar {
            color: #dfdfdf;
            background: #222222;
          }
          #window {
            padding: 1px 2px;
            margin: 1px 12px;
            border-bottom: 2px solid transparent;
          }
          label.module {
            padding: 1px 2px;
            margin: 1px 6px;
          }
          #workspaces button {
            padding: 1px 2px;
            margin: 1px 1px;
            color: #444444;
            border-bottom: 2px solid transparent;
          }
          #workspaces button.hosting-monitor {
            color: #dfdfdf;
          }
          #workspaces button.active.hosting-monitor {
            border-bottom: 2px solid #d65d0e;
          }
          #workspaces button.empty {
            color: #444444;
          }
          #workspaces button.urgent {
            background: #cc241d;
          }
          #clock {
            padding: 1px 6px;
            margin: 1px 10px;
            border-bottom: 2px solid #076678;
          }
          #battery {
            border-bottom: 2px solid #cc241d;
          }
          #memory {
            border-bottom: 2px solid #98971a;
          }
          #cpu {
            border-bottom: 2px solid #427b58;
          }
          #network {
            border-bottom: 2px solid #8f3f71;
          }
          #tray {
            padding: 1px 2px;
            margin: 1px 6px;
            border-bottom: 2px solid #ffaa00;
          }
          tooltip {
            background: rgba(43, 48, 59, 0.8);
            border: 2px solid rgba(100, 114, 125, 0.9);
          }
          tooltip label {
            color: white;
          }
        '';
      };
    };
  };
}
