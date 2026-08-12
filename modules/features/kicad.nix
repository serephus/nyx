{
  den.aspects.kicad = {
    provides.to-users = { user, ... }: {
      nixos = {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [
              ".config/kicad"
              ".local/share/kicad"
            ];
          };
        };
      };
      homeManager = { pkgs, ... }: {
        home.packages = [ pkgs.kicad ];
      };
    };
  };
}
