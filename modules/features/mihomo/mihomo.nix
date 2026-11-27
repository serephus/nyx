{
  den.aspects.mihomo = {
    nixos = { config, ... }: {
      vaultix = {
        secrets = {
          kittyUrl.file = ./kitty-url.age;
          sttUrl.file = ./stt-url.age;
          pqjcUrl.file = ./pqjc-url.age;
        };
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
                  pqjc = {
                    type = "http";
                    url = config.vaultix.placeholder.pqjcUrl;
                    interval = 7200;
                    path = "./pqjc-nodes.yaml";
                    override.additional-prefix = "[pqjc] ";
                    health-check = {
                      enable = true;
                      url = "https://www.gstatic.com/generate_204";
                      interval = 120;
                      timeout = 3000;
                      lazy = false;
                      expected-status = 204;
                    };
                  };
                  kitty = {
                    type = "http";
                    url = config.vaultix.placeholder.kittyUrl;
                    interval = 7200;
                    path = "./kitty-nodes.yaml";
                    override.additional-prefix = "[kitty] ";
                    health-check = {
                      enable = true;
                      url = "https://www.gstatic.com/generate_204";
                      interval = 120;
                      timeout = 3000;
                      lazy = false;
                      expected-status = 204;
                    };
                  };
                  stt = {
                    type = "http";
                    url = config.vaultix.placeholder.sttUrl;
                    interval = 7200;
                    path = "./stt-nodes.yaml";
                    override.additional-prefix = "[stt] ";
                    health-check = {
                      enable = true;
                      url = "https://www.gstatic.com/generate_204";
                      interval = 120;
                      timeout = 3000;
                      lazy = false;
                      expected-status = 204;
                    };
                  };
                };

                proxy-groups = [
                  {
                    name = "PROXY";
                    type = "select";
                    proxies = [
                      "AUTO"
                      "FALLBACK"
                      "DIRECT"
                    ];
                    use = [
                      "pqjc"
                      "kitty"
                      "stt"
                    ];
                  }
                  {
                    name = "AUTO";
                    type = "url-test";
                    use = [
                      "pqjc"
                      "kitty"
                      "stt"
                    ];
                    url = "https://www.gstatic.com/generate_204";
                    interval = 120;
                    timeout = 3000;
                    tolerance = 50;
                    lazy = false;
                    max-failed-times = 3;
                    expected-status = 204;
                  }
                  {
                    name = "FALLBACK";
                    type = "fallback";
                    use = [
                      "kitty"
                      "pqjc"
                      "stt"
                    ];
                    url = "https://www.gstatic.com/generate_204";
                    interval = 60;
                    timeout = 3000;
                    lazy = false;
                    max-failed-times = 3;
                    expected-status = 204;
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
      programs = {
        qutebrowser = {
          keyBindings.normal = {
            "<Ctrl-l>" = "config-cycle content.proxy http://localhost:7890 none";
            "zz" = "hint links spawn yt-dlp -P ~/res/downloads --proxy http://localhost:7890 {hint-url}";
          };
          settings.content.proxy = "http://localhost:7890";
        };
        fish.shellAbbrs.proxy = "http_proxy=http://localhost:7890 https_proxy=http://localhost:7890";
      };
    };
  };
}
