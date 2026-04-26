{ self, inputs, ... }:
{
  # nyx should be a laptop with systemd-boot and home-manager
  flake.modules.nixos.nyx = {
    imports = [
      inputs.hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
      self.modules.nixos.laptop

      self.modules.nixos.nix-mirror-ustc
      self.modules.nixos.nix-opinionated

      self.modules.nixos.v2client

      # laptop enables wireless by default, we just add
      # specific wifi access point here
      self.modules.nixos.glwifi
    ];
  };
}
