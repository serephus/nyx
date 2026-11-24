{ inputs, ... }: {
  den.aspects.xmmrpc = {
    nixos = {
      imports = [ inputs.xmmrpc.nixosModules.default ];
      services.xmmrpc = {
        enable = true;
        autoStart = true;
        settings = {
          apn = "bjlenovo12.njm2mapn";
          writeResolv = false;
          metric = 10000;
        };
      };
      # The WWAN APN only reaches Chinese resolvers; Google/Cloudflare DNS
      # times out on it, which breaks name resolution (and the hotspot's
      # clients) when WiFi is down. Keep reachable resolvers first.
      networking.nameservers = [
        "223.5.5.5"
        "119.29.29.29"
        "8.8.8.8"
        "8.8.4.4"
        "1.1.1.1"
      ];
    };

    provides.to-users = {
      homeManager = { lib, ... }: {
        programs.waybar = {
          settings.main = {
            modules-right = lib.mkOrder 9999 [ "network#wwan" ];

            # Fibocom L850-GL WWAN modem (xmm7360), exposed as wwan0.
            "network#wwan" = {
              interface = "wwan0";
              interval = 1;
              format = "󰒢 {ipaddr}";
              # hide the module entirely until wwan0 actually has an IP
              format-disconnected = "";
              format-linked = "";
              tooltip-format = "{ifname} · {ipaddr}";
            };
          };

          style = ''
            #network.wwan {
              border-bottom: 2px solid #d79921;
            }
          '';
        };
      };
    };
  };
}
