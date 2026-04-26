{ self, inputs, ... }:
{
  # nyx should be a laptop with systemd-boot and home-manager
  flake.modules.nixos.nyx = {
    imports = [
      inputs.hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
      self.modules.nixos.laptop

      self.modules.nixos.nix-mirror-ustc
    ];
  };
}
