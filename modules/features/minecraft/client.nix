{
  den.aspects.minecraft-client = {
    provides.to-users = { user, ... }: {
      nixos = {
        preservation.preserveAt."/persist" = {
          users.${user.userName} = {
            directories = [
              ".local/share/PrismLauncher"
            ];
          };
        };

      };
      homeManager = { pkgs, ... }: {
        home.packages = [ pkgs.prismlauncher ];
      };
    };
  };
}
