{ self, ... }:
{
  flake.modules.homeManager.bibata =
    { pkgs, lib, ... }:
    {
      home.pointerCursor = {
        gtk.enable = true;
        package = lib.mkDefault pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 16;
      };
    };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.bibata
    ];
  };
}
