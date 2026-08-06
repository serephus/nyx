{ den, ... }: {

  # immutable users
  den.default.nixos.users.mutableUsers = false;

  # default root password
  den.default.nixos.users.users.root.hashedPassword =
    "$y$j9T$vmrHUvAuXfmw23ZWlTAFy0$pl4hBYuUzxYPoo7Z3IAPloJ.AZN0jZDeIKgmY/qspf0";

  # we always use en_US.UTF-8 locale
  den.default.nixos.i18n.defaultLocale = "en_US.UTF-8";

  # default environment variables
  den.default.nixos.environment.sessionVariables.NIXOS_OZONE_WL = "1";
  den.default.homeManager.home.sessionVariables.NIXOS_OZONE_WL = "1";
}
