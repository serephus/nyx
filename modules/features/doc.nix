{
  # enable various docs, good for dev
  den.aspects.doc = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.man-pages
        pkgs.man-pages-posix
      ];
      documentation = {
        dev.enable = true;
        man = {
          enable = true;
          man-db.enable = true;
        };
      };
    };
  };
}
