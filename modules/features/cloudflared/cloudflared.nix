{
  den.aspects.cloudflared = host: url: {
    nixos = { config, ... }: {
      vaultix.secrets = {
        # cert is actually not required for our setup
        cloudflaredCertificate.file = ./cloudflared-certificate.age;
        cloudflaredCredential.file = ./cloudflared-credential.age;
      };
      services.cloudflared = {
        enable = true;
        certificateFile = config.vaultix.secrets.cloudflaredCertificate.path;
        tunnels = {
          "e199d1c4-c72e-4e6b-a440-3077c0d387a0" = {
            credentialsFile = config.vaultix.secrets.cloudflaredCredential.path;
            default = "http_status:404";
            ingress."${host}".service = url;
          };
        };
      };
    };
  };
}
