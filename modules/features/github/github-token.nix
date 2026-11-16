{
  # Parametric so each user gets a distinct aspect identity/module; a shared
  # aspect included from multiple user scopes would be deduplicated and only
  # one user's NixOS config would survive.
  #
  # github and nixit include this automatically via provides.to-users, so
  # enabling either on a host declares the token for every user on that host.
  # Include it manually from a user aspect only if the token is needed without
  # gh/nixit.
  den.aspects.github-token = user: {
    provides.to-hosts = {
      nixos = {
        vaultix.secrets."githubToken-${user}" = {
          file = ./github-token.age;
          owner = user;
          # Only the owner (and root) may read the token.
          mode = "0400";
        };
      };
    };
  };
}
