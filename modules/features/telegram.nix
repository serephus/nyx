{
  den.aspects.telegram = {
    provides.to-users = { user, ... }: {
      nixos = {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [ ".local/share/TelegramDesktop" ];
          };
        };
      };
      homeManager = { pkgs, ... }: {
        home.packages = [ pkgs.telegram-desktop ];
      };
    };
  };
}
