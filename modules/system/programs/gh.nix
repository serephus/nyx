{ self, ... }:
{
  flake.modules.homeManager.gh = {
    programs.gh = {
      enable = true;
    };
  };

  flake.modules.homeManager.basic = {
    imports = [
      self.modules.homeManager.gh
    ];
  };
}
