{
  den.aspects.deepseek-apikey = user: {
    provides.to-hosts = {
      nixos = {
        vaultix.secrets."deepseek-apikey-${user}" = {
          file = ./deepseek-apikey.age;
          owner = user;
          mode = "0400";
        };
      };
    };
  };
}
