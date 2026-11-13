{
  den.aspects.termusic = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.termusic
      ];
    };
    provides.to-users = {
      nixos = { user, ... }: {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [
              ".config/termusic"
            ];
          };
        };
      };
    };
  };
}
