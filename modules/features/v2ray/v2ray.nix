{ den, ... }: {
  den.aspects.v2-secrets = {
    nixos = { config, ... }: {
      vaultix = {
        secrets = {
          v2-uuid.file = ./v2-uuid.age;
        };
        templates =
          let
            serverPort = 10086;
            mkOutbound =
              {
                addr,
                port,
                uuid,
                protocol ? "vmess",
                encryption ? "chacha20-poly1305",
              }:
              {
                protocol = protocol;
                settings = {
                  vnext = [
                    {
                      address = addr;
                      port = port;
                      users = [
                        {
                          encryption = encryption;
                          id = uuid;
                        }
                      ];
                    }
                  ];
                };
              };
            mkInbound =
              {
                port,
                uuid,
                protocol ? "vmess",
              }:
              {
                listen = "0.0.0.0";
                port = port;
                protocol = protocol;
                settings = {
                  clients = [
                    {
                      id = uuid;
                    }
                  ];
                };
              };
          in
          {
            v2server = {
              mode = "644";
              content = builtins.toJSON {
                inbounds = map mkInbound [
                  {
                    uuid = config.vaultix.placeholder.v2-uuid;
                    port = serverPort;
                  }
                ];
                outbounds = [
                  {
                    protocol = "freedom";
                  }
                ];
              };
            };

            v2client = {
              mode = "644";
              content = builtins.toJSON {
                inbounds = [
                  {
                    listen = "0.0.0.0";
                    port = 1080;
                    protocol = "socks";
                  }
                  {
                    listen = "0.0.0.0";
                    port = 8080;
                    protocol = "http";
                  }
                ];
                outbounds = map mkOutbound [
                  {
                    # placeholder is a hash256 digest string
                    # so we could not use it as int type
                    addr = "vex.sereph.us";
                    uuid = config.vaultix.placeholder.v2-uuid;
                    port = serverPort;
                  }
                ];
              };
            };
          };
      };
    };
  };

  den.aspects.v2client = {
    includes = [ den.aspects.v2-secrets ];
    nixos = { config, ... }: {
      services.v2ray = {
        enable = true;
        configFile = config.vaultix.templates.v2client.path;
      };
    };
  };

  den.aspects.v2server = {
    includes = [ den.aspects.v2-secrets ];
    nixos = { config, ... }: {
      services.v2ray = {
        enable = true;
        configFile = config.vaultix.templates.v2server.path;
      };
    };
  };
}
