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
            "${config.home.homeDirectory}/dev/nix"
            "${config.home.homeDirectory}/dev/koka"
            "${config.home.homeDirectory}/dev/idris2"
            "${config.home.homeDirectory}/dev/haskell"
            "${config.home.homeDirectory}/dev/zig"
          ];
        };
      };
    };
  };
}
