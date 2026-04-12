{ self, ... }:
{
  # bat could be enabled both in nixos and home manager
  flake.modules.nixos.bat = {
    programs.bat = {
      enable = true;
    };
  };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.bat
    ];
  };

  flake.modules.homeManager.bat = {
    programs.bat = {
      enable = true;
    };
  };

  flake.modules.homeManager.basic = {
    imports = [
      self.modules.homeManager.bat
    ];
  };
}
