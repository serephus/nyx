{ inputs, ... }: {
  den.aspects.wpaperd = {
    provides.to-users.homeManager = {
      services.wpaperd = {
        enable = true;
        settings = {
          default = {
            duration = "5m";
            mode = "stretch";
            sorting = "random";
          };
          any.path = inputs.wallpaper;
        };
      };
    };
  };
}
