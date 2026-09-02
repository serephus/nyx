{
  den.aspects.niri = {
    nixos = {
      programs.niri.enable = true;
    };
    provides.to-users = { user, ... }: {
      nixos = {
        # remove this once we've config niri with hm
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            files = [ ".config/niri/config.kdl" ];
          };
        };
      };
      homeManager = { lib, ... }: {
        # we'll need to add more configs for niri once we move to hm 26.11
        programs.waybar.settings.main = {
          modules-left = lib.mkOrder 102 [
            "niri/workspaces"
            "niri/window"
          ];

          # "niri/workspaces" = {
          #   all-outputs = true;
          # };
        };
      };
    };
  };
}
