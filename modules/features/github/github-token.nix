{
  den.aspects.github-token = {
    provides.to-users = { user, ... }: {
      nixos = {
        vaultix.secrets.githubToken = {
          file = ./github-token.age;
          owner = user.userName;
          # Only the owner (and root) may read the token.
          mode = "0400";
        };
      };
    };
  };
}
