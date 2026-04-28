{ self, ... }:
{
  flake.modules.nixos.yazi = {
    programs.yazi = {
      enable = true;
    };
  };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.yazi
    ];
  };

  flake.modules.homeManager.yazi = {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      settings.mgr.show_hidden = true;
    };
  };

  flake.modules.homeManager.basic = {
    imports = [
      self.modules.homeManager.yazi
    ];
  };
}
