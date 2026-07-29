{ self, ... }:
{
  flake.modules.nixos.v2ray =
    { config, ... }:
    {
      imports = [
        self.modules.nixos.vaultix
      ];
      vaultix =
        let
          mkOutbound =
            {
              addr,
              port,
              uuid,
              serverName,
              publicKey,
              shortId,
              spiderX,
              protocol ? "vless",
              encryption ? "none",
            }:
            {
              protocol = protocol;
              settings = {
                address = addr;
                port = port;
                id = uuid;
                encryption = encryption;
                flow = "xtls-rprx-vision";
              };
              streamSettings = {
                network = "tcp";
                security = "reality";
                realitySettings = {
                  fingerprint = "chrome";
                  serverName = serverName;
                  sni = serverName;
                  publicKey = publicKey;
                  shortId = shortId;
                  spiderX = spiderX;
                };
              };
            };
        in
        {
          secrets = {
            # since v2ray's vmess outbound config doesn't support string port
            # we use a public port here
            v2addr = {
              file = ./v2addr.age;
            };
            v2uuid = {
              file = ./v2uuid.age;
            };
            v2pk = {
              file = ./v2pk.age;
            };
            v2server = {
              file = ./v2server.age;
            };
            v2sid = {
              file = ./v2sid.age;
            };
            v2sp = {
              file = ./v2sp.age;
            };
          };
          templates = {
            xrayClient = {
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
                    addr = config.vaultix.placeholder.v2addr;
                    uuid = config.vaultix.placeholder.v2uuid;
                    port = 443;
                    serverName = config.vaultix.placeholder.v2server;
                    publicKey = config.vaultix.placeholder.v2pk;
                    shortId = config.vaultix.placeholder.v2sid;
                    spiderX = config.vaultix.placeholder.v2sp;
                  }
                ];
              };
            };
          };
        };
    };
}
