{ inputs, ... }:
{
  flake-file.inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # this gives output homeConfigurations
  imports = [ inputs.home-manager.flakeModules.home-manager ];
}
