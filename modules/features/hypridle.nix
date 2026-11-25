{
  den.aspects.hypridle = {
    # hypridle is compositor-agnostic, but its commands have to match niri.
    provides.to-users.homeManager = {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            before_sleep_cmd = "loginctl lock-session";
            # niri powers the monitors back on automatically when input arrives.
          };

          listener = [
            {
              timeout = 1200;
              on-timeout = "niri msg action power-off-monitors";
            }
          ];
        };
      };
    };
  };
}
