{ self, ... }:
{
  flake.modules.nixos.procs =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.procs
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.procs
    ];
  };
}
