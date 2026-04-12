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
    programs.difftastic.enable = true;
  };

  flake.modules.homeManager.basic = {
    imports = [
      self.modules.homeManager.difftastic
    ];
  };
}
