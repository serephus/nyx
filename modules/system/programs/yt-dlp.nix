{ self, ... }:
{
  flake.modules.nixos.yt-dlp =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.yt-dlp
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.yt-dlp
    ];
  };
}
