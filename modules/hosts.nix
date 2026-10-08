{ lib, ... }: {
  # serephus user at nyx host.
  den.hosts.x86_64-linux.nyx.users.serephus = { };
  # define an standalone home-manager for serephus
  # how do I add configs to standalone home configs?
  den.homes.x86_64-linux."serephus@nyx" = { };

  # serephus user at x1c host.
  den.hosts.x86_64-linux.x1c.users.serephus = { };
  den.homes.x86_64-linux."serephus@x1c" = { };

  # serephus user at nova host.
  den.hosts.x86_64-linux.nova.users.serephus = { };
  den.homes.x86_64-linux."serephus@nova" = { };

  # minimal host for livecd, etc
  den.hosts.x86_64-linux.minimal.users = { };

  # enable hm by default
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
}
