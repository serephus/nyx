{
  den.aspects.difftastic = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.difftastic
      ];
    };

    provides.to-users.homeManager = {
      programs = {
        difftastic.enable = true;
        # enable git.difftastic will make patch generation painful
        # so we just add some git alias
        git.settings.alias = {
          # `git log` with patches shown with difftastic.
          dl = "-c diff.external=difft log -p --ext-diff";
          # Show the most recent commit with difftastic.
          ds = "-c diff.external=difft show --ext-diff";
          # `git diff` with difftastic.
          dft = "-c diff.external=difft diff";
        };
      };
    };
  };
}
