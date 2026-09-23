{
  den.aspects.wifi = {
    nixos = { config, ... }: {
      vaultix.secrets.wifiSecrets = {
        file = ./wifi-secrets.age;
        mode = "0644";
      };
      networking.wireless = {
        enable = true;
        # the secret here may cause trouble during bootstrapping
        secretsFile = config.vaultix.secrets.wifiSecrets.path;
        networks."glwifi-5g" = {
          pskRaw = "ext:psk_glwifi";
          priority = 1000;
        };
      };
    };
  };
}
