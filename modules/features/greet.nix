{
  den.aspects.greet.nixos = { pkgs, ... }: {
    services.greetd.enable = true;
    programs.regreet = {
      enable = true;
      # TODO: not working right now
      # let not set background for now
      cursorTheme = {
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
      };
      cageArgs = [
        "-s"
        "-d"
        "-m"
        "last"
      ];
    };
  };
}
