{
  den.aspects.minecraft-client = {
    provides.to-users = {
      homeManager = { pkgs, ... }: {
        home.packages = [ pkgs.prismlauncher ];
      };
    };
  };
}
