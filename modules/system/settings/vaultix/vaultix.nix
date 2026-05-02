{ inputs, ... }:
{
  flake.modules.nixos.vaultix = {
    imports = [ inputs.vaultix.nixosModules.default ];
    services.userborn.enable = true;
  };
}
