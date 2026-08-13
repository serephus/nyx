{ lib, ... }: {
  # serephus user at nyx host.
  den.hosts.x86_64-linux.nyx.users.serephus = { };

  # serephus user at x1c host.
  den.hosts.x86_64-linux.x1c.users.serephus = { };

  # serephus user at x1c host.
  den.hosts.x86_64-linux.nova.users.serephus = { };

  # minimal host for livecd, etc
  den.hosts.x86_64-linux.minimal.users = { };

  # define an standalone home-manager for serephus
  # how do I add configs to standalone home configs
  den.homes.x86_64-linux."serephus@nyx" = { };

  den.homes.x86_64-linux."serephus@x1c" = { };

  # enable hm by default
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
}
