{ den, ... }: {
  den.aspects.tmux = {
    nixos = {
      programs.tmux = {
        enable = true;
        baseIndex = 1;
        keyMode = "vi";
      };
    };
    provides.to-users = {
      homeManager = {
        programs.tmux = {
          enable = true;
          baseIndex = 1;
          keyMode = "vi";
          prefix = "C-a";
        };
      };
    };
  };
}
