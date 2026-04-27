{ self, ... }:
{
  flake.modules.nixos.doc =
    { pkgs, ... }:
    {
      # man docs
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

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.doc
    ];
  };
}
