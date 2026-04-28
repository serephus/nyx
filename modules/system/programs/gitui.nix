{ self, ... }:
{
  flake.modules.nixos.gitui =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.gitui
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.gitui
    ];
  };

  flake.modules.homeManager.gitui = {
    programs.gitui = {
      enable = true;
    };
  };

  flake.modules.homeManager.basic = {
    imports = [
      self.modules.homeManager.gitui
    ];
  };
}
