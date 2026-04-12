{ self, ... }:
{
  # bottom config is simple
  flake.modules.nixos.bottom =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.bottom
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.bottom
    ];
  };

  flake.modules.homeManager.bottom = {
    programs.bottom.enable = true;
  };

  flake.modules.homeManager.basic = {
    imports = [
      self.modules.homeManager.bottom
    ];
  };
}
