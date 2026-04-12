{ inputs, ... }:
{
  # map flake.modules.nixos.nyx => nixosConfiguration.nix
  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "nyx";
}
