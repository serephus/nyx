{ den, inputs, ... }: {
  den.aspects.truesight =
    let
      truesightPort = 11440;
    in
    {
      includes = [
        (den.aspects.cloudflared "truesight.sereph.us" "http://localhost:${toString truesightPort}")
      ];

      nixos = { config, ... }: {
        imports = [ inputs.truesight.nixosModules.default ];
        vaultix.secrets = {
          steamApiKey.file = ./steam-api-key.age;
        };
        services.truesight = {
          enable = true;
          steamApiKeysFile = config.vaultix.secrets.steamApiKey.path;
          patch = {
            name = "7.41";
            start = 1792200000;
          };
          port = truesightPort;
          openFirewall = true;
          nginx.enable = false;
        };
        preservation.preserveAt."/persist" = {
          directories = [
            "/var/lib/clickhouse"
          ];
        };
      };
    };
}
