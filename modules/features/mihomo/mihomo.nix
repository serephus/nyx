{
  den.aspects.mihomo = {
    nixos = { config, ... }: {
      vaultix = {
        secrets.kittyUrl.file = ./kitty-url.age;
        templates.mihomoConfig = {
          mode = "0644";
          content =
            let
              mihomoConfig = {
                mixed-port = 7890;
                allow-lan = true;
                bind-address = "*";
                ipv6 = true;
                log-level = "info";
                external-controller = "127.0.0.1:9090";
                mode = "rule";

                geodata-mode = true;
                geo-auto-update = true;
                geo-update-interval = 24;
                geox-url = {
                  geoip = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat";
                  geosite = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat";
                  mmdb = "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/country.mmdb";
                };

                proxy-providers = {
                  kitty = {
                    type = "http";
                    url = config.vaultix.placeholder.kittyUrl;
                    interval = 7200;
                    path = "./kitty-nodes.yaml";
                    override.additional-prefix = "[kitty] ";
                    health-check = {
                      enable = true;
                      url = "https://www.gstatic.com/generate_204";
                      interval = 300;
                      timeout = 5000;
                      lazy = true;
                      expected-status = 204;
                    };
                  };
                };

                proxy-groups = [
                  {
                    name = "PROXY";
                    type = "select";
                    proxies = [ "AUTO" ];
                    use = [ "kitty" ];
                  }
                  {
                    name = "AUTO";
                    type = "url-test";
                    use = [ "kitty" ];
                    url = "http://www.gstatic.com/generate_204";
                    interval = 300;
                    tolerance = 50;
                  }
                ];

                rules = [
                  "GEOSITE,cn,DIRECT"
                  "IP-CIDR,10.0.0.0/8,DIRECT"
                  "IP-CIDR,172.16.0.0/12,DIRECT"
                  "IP-CIDR,192.168.0.0/16,DIRECT"
                  "IP-CIDR,127.0.0.0/8,DIRECT"
                  "IP-CIDR,100.64.0.0/10,DIRECT"
                  "IP-CIDR,169.254.0.0/16,DIRECT"
                  "IP-CIDR6,::1/128,DIRECT"
                  "IP-CIDR6,fc00::/7,DIRECT"
                  "IP-CIDR6,fe80::/10,DIRECT"
                  "GEOIP,CN,DIRECT"
                  "MATCH,PROXY"
                ];
              };
            in
            # toYAML actually convert to a json string since json is a subset of yaml
            builtins.toJSON mihomoConfig;
        };
      };
      services.mihomo = {
        enable = true;
        configFile = config.vaultix.templates.mihomoConfig.path;
      };
      preservation.preserveAt."/persist" = {
        directories = [ "/var/lib/private/mihomo" ];
      };
    };
    provides.to-users.homeManager = {
      programs.qutebrowser = {
        keyBindings.normal = {
          "<Ctrl-l>" = "config-cycle content.proxy socks5://localhost:7890 none";
          "zz" = "hint links spawn yt-dlp -P ~/res/downloads --proxy socks5://localhost:7890 {hint-url}";
        };
      };
    };
  };
}
