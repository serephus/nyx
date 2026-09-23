{ den, inputs, ... }: {
  den.aspects.cocoon = {
    includes = [
      (den.aspects.cloudflared "cocoon.sereph.us" "http://localhost:11438")
    ];
    nixos = { config, ... }: {
      imports = [ inputs.cocoon.nixosModules.default ];
      vaultix.secrets.cocoonSecret.file = ./cocoon-secret.age;
      services.cocoon-paste = {
        enable = true;
        secretFile = config.vaultix.secrets.cocoonSecret.path;
        settings = {
          COCOON_BIND = "127.0.0.1:11438";
          COCOON_DB = "/var/lib/cocoon-paste/cocoon.db";
        };
      };
      preservation.preserveAt."/persist" = {
        directories = [
          "/var/lib/cocoon-paste"
        ];
      };
    };
  };
}
