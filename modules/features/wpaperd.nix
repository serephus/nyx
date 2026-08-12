{
  den.aspects.wpaperd = {
    provides.to-users.homeManager = { config, ... }: {
      services.wpaperd = {
        enable = true;
        settings = {
          default = {
            duration = "5m";
            mode = "stretch";
            sorting = "random";
          };
          any.path = "${config.home.homeDirectory}/res/images/wallpaper";
        };
      };
    };
  };
}
