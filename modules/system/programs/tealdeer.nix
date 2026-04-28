{ self, ... }:
{
  flake.modules.nixos.tealdeer =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.tealdeer
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.tealdeer
    ];
  };

  flake.modules.homeManager.tealdeer = {
    programs.tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };
  };

  flake.modules.homeManager.basic = {
    imports = [
      self.modules.homeManager.tealdeer
    ];
  };
}
