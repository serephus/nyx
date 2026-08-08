{ den, ... }: {
  # serephus user aspect
  den.aspects.serephus = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
    ];

    homeManager = {
      # home manager configs
      # programs.ssh.enable = true;
    };

    provides.to-hosts = { user, ... }: {
      nixos = {
        users.users.serephus = {
          hashedPassword = "$y$j9T$9YAnjIHNRAokTtsXAE3HD/$ZbFS7C9ATg9ZX/mxcPrJaFf1/OJnKcT7nHd3rQ2Xhv2";
          # TODO: change this to yubikey
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJCl8X5dDv+19y323NZkCbSMiou8phYjbTvTUou5Ju+w i@sereph.us"
          ];
        };
      };
      homeManager = {
        programs.git.settings.user = {
          name = "${user.userName}";
          email = "i@sereph.us";
        };
      };
    };
  };
}
