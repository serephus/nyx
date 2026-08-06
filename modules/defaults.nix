{ lib, ... }: {
  # states
  den.default.nixos.system.stateVersion = "26.05";
  den.default.homeManager.home.stateVersion = "26.05";

  # immutable users
  den.default.nixos.users.mutableUsers = false;

  # default root password
  den.default.nixos.users.users.root.hashedPassword =
    "$y$j9T$vmrHUvAuXfmw23ZWlTAFy0$pl4hBYuUzxYPoo7Z3IAPloJ.AZN0jZDeIKgmY/qspf0";

  # sudo-rs
  den.default.nixos.security.sudo.enable = false;
  den.default.nixos.security.sudo-rs.enable = true;

  # we always use en_US.UTF-8 locale
  den.default.nixos.i18n.defaultLocale = "en_US.UTF-8";

  # default environment variables
  den.default.nixos.environment.sessionVariables.NIXOS_OZONE_WL = "1";
  den.default.homeManager.home.sessionVariables.NIXOS_OZONE_WL = "1";

  # enable hm by default
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
}
