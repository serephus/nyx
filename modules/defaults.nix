{
  # default configs applied to all hosts, some other
  # common configs are grouped into separate features

  # we don't want mutable user, keep as many thing as declarative as possible
  den.default.nixos.users.mutableUsers = false;

  # every hosts have the same root password
  den.default.nixos.users.users.root.hashedPassword =
    "$y$j9T$vmrHUvAuXfmw23ZWlTAFy0$pl4hBYuUzxYPoo7Z3IAPloJ.AZN0jZDeIKgmY/qspf0";

  # always use en_US.UTF-8 locale
  den.default.nixos.i18n.defaultLocale = "en_US.UTF-8";
}
