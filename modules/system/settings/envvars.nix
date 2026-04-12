{ self, ... }:
{
  flake.modules.nixos.envvars = {
    # this should fix some issue caused by environment variable
    # differences between system and user programs
    # although we still have other envvar to add like fcitx5-related ones
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };

  flake.modules.nixos.minimal = {
    imports = [
      self.modules.nixos.envvars
    ];
  };

  flake.modules.homeManager.envvars = {
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };

  flake.modules.homeManager.minimal = {
    imports = [
      self.modules.homeManager.envvars
    ];
  };
}
