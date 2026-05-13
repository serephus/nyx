{ self, ... }:
{
  flake.modules.nixos.git-filter-repo =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.git-filter-repo
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.git-filter-repo
    ];
  };
}
