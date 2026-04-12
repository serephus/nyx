{ self, inputs, ... }:
let
  home-manager-config = {
    home-manager = {
      verbose = true;
      useUserPackages = true;
      useGlobalPkgs = true;
    };
  };
in
{
  flake.modules.nixos.home-manager = {
    imports = [
      # home manager nixos module
      inputs.home-manager.nixosModules.home-manager
      # common home manager configs
      home-manager-config
    ];
  };

  flake.modules.nixos.minimal = {
    imports = [
      self.modules.nixos.home-manager
    ];
  };
}
