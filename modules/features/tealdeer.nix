{
  den.aspects.tealdeer = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.tealdeer ];
    };
    provides.to-users.homeManager = {
      programs.tealdeer = {
        enable = true;
        settings.updates.auto_update = true;
      };
    };
  };
}
