{ inputs, ... }:
{
  flake.modules.nixos.disko = {
    # this gives various configs under nixos configs
    imports = [ inputs.disko.nixosModules.disko ];
  };
}
