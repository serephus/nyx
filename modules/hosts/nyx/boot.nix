{ self, ... }:
{
  # nyx should be a laptop with systemd-boot and home-manager
  flake.modules.nixos.nyx = {
    imports = [
      self.modules.nixos.systemd-boot
    ];
  };
}
