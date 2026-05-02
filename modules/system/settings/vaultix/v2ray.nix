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
          };
          templates = {
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
                    addr = config.vaultix.placeholder.v2addr;
                    uuid = config.vaultix.placeholder.v2uuid;
                    port = 28349;
                  }
                ];
              };
            };
          };
        };
    };
}
