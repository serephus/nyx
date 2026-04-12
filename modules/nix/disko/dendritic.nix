{ inputs, ... }:
{
  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # this gives a diskoConfigurations output for disko/disko-install
  imports = [ inputs.disko.flakeModules.disko ];
}
