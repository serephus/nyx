{ den, inputs, ... }: {
  den.aspects.cocoon = {
    includes = [
      (den.aspects.cloudflared "cocoon.sereph.us" "http://localhost:11438")
    ];
    nixos = { config, ... }: {
      imports = [ inputs.cocoon.nixosModules.default ];
      vaultix.secrets = {
        cocoonSecret.file = ./cocoon-secret.age;
        telegramBotToken.file = ./cocoon-bot-token.age;
      };
      services.cocoon-paste = {
        enable = true;
        botTokenFile = config.vaultix.secrets.telegramBotToken.path;
        webhookSecretFile = config.vaultix.secrets.cocoonSecret.path;
        settings = {
          COCOON_BIND = "127.0.0.1:11438";
          COCOON_DB = "/var/lib/cocoon-paste/cocoon.db";
          COCOON_PUBLIC_URL = "https://cocoon.sereph.us";
          COCOON_TELEGRAM_PROXY = "http://localhost:7890";
        };
      };
      preservation.preserveAt."/persist" = {
        directories = [
          "/var/lib/private/cocoon-paste"
        ];
      };
    };
  };
}
