{ self, ... }:
{
  flake.modules.nixos.you-get =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.you-get
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.you-get
    ];
  };
}
