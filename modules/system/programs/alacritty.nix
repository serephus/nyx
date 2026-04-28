{ self, ... }:
{
  flake.modules.homeManager.alacritty = {
    programs.alacritty = {
      enable = true;
      settings = {
        # do we need to use lib.getExec?
        terminal.shell = "fish";
        # this font have no korean or japanese variant?
        font.normal.family = "FiraCode Nerd Font Mono";
      };
    };
  };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.alacritty
    ];
  };
}
