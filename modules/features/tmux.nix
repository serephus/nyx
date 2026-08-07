{
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
        # I don't have many tmux configs for now
        # maybe add more later
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
