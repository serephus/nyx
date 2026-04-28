{ self, ... }:
{
  flake.modules.nixos.btrfs =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.btrfs-progs
      ];
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.btrfs
    ];
  };
}
