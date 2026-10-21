{
  # Per-host tunnel: a connector can only answer for hostnames in its own ingress
  # config, so each host that runs cloudflared needs its own tunnel (own id + creds).
  den.aspects.cloudflaredTunnel = { id, credentialFile }: {
    nixos = { config, lib, ... }: {
      options.cloudflared.tunnelId = lib.mkOption {
        type = lib.types.str;
        description = "Cloudflare tunnel this host runs a connector for.";
      };

      config = {
        cloudflared.tunnelId = id;

        vaultix.secrets.cloudflaredCredential.file = credentialFile;

        services.cloudflared = {
          enable = true;
          tunnels."${id}" = {
            credentialsFile = config.vaultix.secrets.cloudflaredCredential.path;
            default = "http_status:404";
          };
        };
      };
    };
  };

  # Attach a public hostname to this host's tunnel. The tunnel key comes from the
  # plain `cloudflared.tunnelId` option above, never from
  # `config.services.cloudflared.tunnels` itself: mapping over that option while
  # defining it needs the option's attr names, which are only known after this
  # definition is evaluated => infinite recursion.
  den.aspects.cloudflared = host: url: {
    nixos = { config, ... }: {
      services.cloudflared.tunnels."${config.cloudflared.tunnelId}".ingress."${host}".service = url;
    };
  };
}
