{ den, inputs, ... }: {
  den.aspects.komi = {
    includes = [
      (den.aspects.cloudflared "komi.sereph.us" "http://localhost:11441")
    ];

    nixos = {
      imports = [ inputs.komi.nixosModules.default ];
      services.komi = {
        enable = true;
        address = "127.0.0.1";
        port = 11441;
        secureCookies = true;
        trustProxy = true;
        allowRegistration = true;
      };
      preservation.preserveAt."/persist" = {
        directories = [
          "/var/lib/komi"
        ];
      };
    };
  };
}
