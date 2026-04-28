{ self, ... }:
{
  flake.modules.homeManager.hypridle =
    { lib, ... }:
    {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            after_sleep_cmd = "hyprctl dispatch dpms on";
            ignore_dbus_inhibit = false;
          };

          listener = lib.mkOrder 101 [
            {
              timeout = 1200;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
          ];
        };
      };
    };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.hypridle
    ];
  };
}
