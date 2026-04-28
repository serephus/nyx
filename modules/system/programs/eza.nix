{ self, ... }:
{
  flake.modules.homeManager.eza = {
    programs.eza = {
      enable = true;
    };
  };

  flake.modules.homeManager.basic = {
    imports = [
      self.modules.homeManager.eza
    ];
  };
}
