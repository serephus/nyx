{
  den.aspects.root.nixos = { config, ... }: {
    vaultix = {
      beforeUserborn = [ "rootHashedPasswordFile" ];
      secrets.rootHashedPasswordFile.file = ./root-hashed-password-file.age;
    };
    users.users.root = {
      # every host shares the same root password
      # comment this out only while bootstrapping a fresh machine
      hashedPasswordFile = config.vaultix.secrets.rootHashedPasswordFile.path;
      openssh.authorizedKeys.keyFiles = [
        ./id_ed25519_sk.pub
        ./id_ed25519_sk_yka.pub
      ];
    };
  };
}
