{ self, ... }:
{
  # difftastic have no independent system config
  flake.modules.nixos.difftastic =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.difftastic
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.difftastic
    ];
  };

  flake.modules.homeManager.difftastic = {
    programs = {
      difftastic.enable = true;
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

  flake.modules.homeManager.basic = {
    imports = [
      self.modules.homeManager.difftastic
    ];
  };
}
