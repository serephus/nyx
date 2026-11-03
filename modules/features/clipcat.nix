{
  den.aspects.clipcat = {
    nixos = {
      services.clipcat.enable = true;
    };
    provides.to-users = { user, ... }: {
      nixos = {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            # clipcat keeps its history in
            # $XDG_CACHE_HOME/clipcat/clipcatd-history by default.
            directories = [ ".cache/clipcat" ];
          };
        };
      };
      homeManager = {
        services.clipcat = {
          enable = true;
          daemonSettings = {
            daemonize = false;

            # Track the regular clipboard only. Enabling the primary
            # selection would put every text selection into the history.
            watcher = {
              enable_clipboard = true;
              enable_primary = false;
              enable_secondary = false;
            };
            synchronize_selection_with_clipboard = false;
          };

          # fuzzel is already installed for the Mod+D launcher.
          menuSettings.finder = "fuzzel";
        };
      };
    };
  };
}
