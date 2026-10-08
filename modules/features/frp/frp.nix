{ den, ... }: {
  den.aspects.frp-secret = {
    nixos = {
      vaultix.secrets.frpToken.file = ./frp-token.age;
    };
  };

  den.aspects.frpc = {
    includes = [ den.aspects.frp-secret ];
    nixos = { config, ... }: {
      services.frp = {
        instances = {
          aliyun = {
            enable = true;
            role = "client";
            settings = {
              proxies = [
                {
                  name = "ssh";
                  type = "tcp";
                  localIp = "127.0.0.1";
                  localPort = 22;
                  remotePort = 7001;
                }
              ];
              serverAddr = "aliyun.sereph.us";
              serverPort = 7000;
              auth = {
                method = "token";
                tokenSource = {
                  type = "file";
                  file = config.vaultix.secrets.frpToken.path;
                };
              };
            };
          };
        };
      };
    };
  };

  den.aspects.frps = {
    includes = [ den.aspects.frp-secret ];
    nixos = { config, ... }: {
      services.frp = {
        instances = {
          aliyun = {
            enable = true;
            role = "server";
            settings = {
              auth = {
                method = "token";
                tokenSource = {
                  type = "file";
                  file = config.vaultix.secrets.frpToken.path;
                };
              };
            };
          };
        };
      };
    };
  };
}
