{
  den.aspects.root.nixos = { config, ... }: {
    vaultix = {
      beforeUserborn = [ "rootHashedPasswordFile" ];
      secrets.rootHashedPasswordFile.file = ./root-hashed-password-file.age;
    };
    users.users.root = {
      # every hosts share the same root password
      # we should comment out this line during bootstrap?
      hashedPasswordFile = config.vaultix.secrets.rootHashedPasswordFile.path;
      openssh.authorizedKeys.keyFiles = [
        ./id_ed25519_sk.pub
        ./id_ed25519_sk_yka.pub
      ];
    };
  };
}
