{ den, ... }: {
  # user aspect
  den.aspects.serephus = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user

      den.aspects.ssh
    ];

    homeManager = { pkgs, ... }: {
      # home manager configs
      # programs.ssh.enable = true;
    };

    # user can provide NixOS configurations
    # to any host it is included on
    provides.to-hosts.nixos = { pkgs, ... }: {
      # nixos configs
      users.users.serephus = {
        hashedPassword = "$y$j9T$9YAnjIHNRAokTtsXAE3HD/$ZbFS7C9ATg9ZX/mxcPrJaFf1/OJnKcT7nHd3rQ2Xhv2";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJCl8X5dDv+19y323NZkCbSMiou8phYjbTvTUou5Ju+w i@sereph.us"
        ];
      };
    };
  };
}
