{ den, ... }: {
  # default configs applied to all hosts, some other
  # common configs are grouped into separate features

  # we don't want mutable user, keep as many thing as declarative as possible
  den.default.nixos.users.mutableUsers = false;

  # always use en_US.UTF-8 locale
  den.default.nixos.i18n.defaultLocale = "en_US.UTF-8";

  # always define hostname
  den.default.includes = [ den.batteries.hostname ];
}
