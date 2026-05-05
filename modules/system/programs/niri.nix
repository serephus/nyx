{ self, ... }:
{
  flake.modules.nixos.niri = {
    programs = {
      uwsm = {
        waylandCompositors = {
          niri = {
            prettyName = "Niri";
            comment = "Niri compositor managed by UWSM";
            binPath = "/run/current-system/sw/bin/niri";
          };
        };
      };
      niri.enable = true;
    };
  };

  flake.modules.nixos.desktop = {
    imports = [
      self.modules.nixos.niri
    ];
  };

  flake.modules.homeManager.niri = { };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.niri
    ];
  };
}
