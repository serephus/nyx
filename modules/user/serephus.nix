{ den, ... }: {
  # serephus user aspect
  den.aspects.serephus = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
    ];

    provides.to-hosts = { user, ... }: {
      nixos = { config, ... }: {
        vaultix = {
          beforeUserborn = [ "serephusHashedPasswordFile" ];
          secrets.serephusHashedPasswordFile.file = ./serephus-hashed-password-file.age;
        };
        users.users.serephus = {
          # we should comment out this line during bootstrap?
          hashedPasswordFile = config.vaultix.secrets.serephusHashedPasswordFile.path;
          openssh.authorizedKeys.keyFiles = [
            ./id_ed25519_sk.pub
            ./id_ed25519_sk_yka.pub
          ];
        };
      };
      homeManager = {
        programs.git.settings.user = {
          name = user.userName;
          email = "i@sereph.us";
        };
      };
    };
  };
}
