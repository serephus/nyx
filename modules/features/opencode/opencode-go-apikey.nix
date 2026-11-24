{
  den.aspects.opencode-go-apikey = user: {
    provides.to-hosts = {
      nixos = {
        vaultix.secrets."opencode-go-apikey-${user}" = {
          file = ./opencode-go-apikey.age;
          owner = user;
          mode = "0400";
        };
      };
    };
  };
}
