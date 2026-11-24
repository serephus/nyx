{ den, ... }: {
  den.schema.host.includes = [ den.batteries.mutual-provider ];

  # default configs applied to all hosts, some other
  # common configs are grouped into separate features

  # we don't want mutable users; keep as much as possible declarative
  # (hosts that use this rely on vaultix/userborn for passwords)
  den.default.nixos.users.mutableUsers = false;

  # always use en_US.UTF-8 locale
  den.default.nixos.i18n.defaultLocale = "en_US.UTF-8";

  # always define hostname
  den.default.includes = [ den.batteries.hostname ];
}
