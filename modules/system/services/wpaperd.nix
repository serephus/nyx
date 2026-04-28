{ self, ... }:
{
  flake.modules.homeManager.wpaperd =
    { config, ... }:
    {
      services.wpaperd = {
        enable = true;
        settings = {
          default = {
            duration = "5m";
            mode = "stretch";
            sorting = "random";
          };
          any = {
            path = "${config.home.homeDirectory}/res/images/wallpaper";
          };
        };
      };
    };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.wpaperd
    ];
  };
}
