{ self, ... }:
{
  # nyx should be a laptop with systemd-boot and home-manager
  flake.modules.nixos.nyx = {
    imports = [
      self.modules.nixos.laptop

      self.modules.nixos.nix-mirror-ustc
      self.modules.nixos.nix-opinionated
    ];
  };
}
