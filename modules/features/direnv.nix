{
  den.aspects.direnv = {
    provides.to-users.homeManager = { config, ... }: {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        config = {
          global.strict_env = true;
          whitelist.prefix = [
            "${config.home.homeDirectory}/dev/nyx"
            "${config.home.homeDirectory}/dev/blog"
            "${config.home.homeDirectory}/dev/rust"
            "${config.home.homeDirectory}/dev/python"
            "${config.home.homeDirectory}/dev/cpp"
            "${config.home.homeDirectory}/dev/misc"
          ];
        };
      };
    };
  };
}
