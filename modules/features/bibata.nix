{
  den.aspects.bibata = {
    provides.to-users.homeManager = { pkgs, lib, ... }: {
      home.pointerCursor = {
        gtk.enable = true;
        package = lib.mkDefault pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 16;
      };
    };
  };
}
