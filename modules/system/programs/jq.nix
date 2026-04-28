{ self, ... }:
{
  flake.modules.nixos.jq =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.jq
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.jq
    ];
  };
}
