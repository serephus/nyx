{
  den.aspects.blender = {
    provides.to-users = { user, ... }: {
      nixos = {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [
              ".config/blender"
            ];
          };
        };
      };
      homeManager = { pkgs, ... }: {
        home.packages = [ pkgs.blender ];
      };
    };
  };
}
