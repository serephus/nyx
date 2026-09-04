{
  den.aspects.copyq = {
    provides.to-users = { user, ... }: {
      nixos = {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [ ".local/share/copyq" ];
          };
        };
      };
      homeManager = {
        services.copyq = {
          enable = true;
          forceXWayland = false;
        };
      };
    };
  };
}
