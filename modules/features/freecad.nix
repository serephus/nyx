{
  den.aspects.freecad = {
    provides.to-users = { user, ... }: {
      nixos = {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [
              ".config/FreeCAD"
              ".local/share/FreeCAD"
            ];
          };
        };
      };
      homeManager = { pkgs, ... }: {
        home.packages = [ pkgs.freecad ];
      };
    };
  };
}
