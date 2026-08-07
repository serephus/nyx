{ den, ... }: {

  # immutable users
  den.default.nixos.users.mutableUsers = false;

  # default root password
  den.default.nixos.users.users.root.hashedPassword =
    "$y$j9T$vmrHUvAuXfmw23ZWlTAFy0$pl4hBYuUzxYPoo7Z3IAPloJ.AZN0jZDeIKgmY/qspf0";

  # always use en_US.UTF-8 locale
  den.default.nixos.i18n.defaultLocale = "en_US.UTF-8";
}
