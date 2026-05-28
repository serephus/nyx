{ inputs, ... }:
{
  flake-file.inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # this gives output homeConfigurations
  imports = [ inputs.home-manager.flakeModules.home-manager ];
}
