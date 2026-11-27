{
  den.aspects.hypridle = {
    # hypridle is compositor-agnostic, but its commands have to match niri.
    provides.to-users.homeManager = {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            before_sleep_cmd = "loginctl lock-session";
          };

          # niri leaks GPU buffers while monitors are off (niri-wm/niri#3295),
          # which can OOM the session. Upstream only has a frame-callback
          # workaround (78b7adfe238d); the real fix (renderer cache cleanup,
          # PR #4750) is still unmerged. Re-enable once a release has either.
          # listener = [
          #   {
          #     timeout = 1200;
          #     on-timeout = "niri msg action power-off-monitors";
          #   }
          # ];
        };
      };
    };
  };
}
