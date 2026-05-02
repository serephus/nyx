{ inputs, ... }:
{
  flake-file.inputs = {
    vaultix = {
      url = "github:milieuim/vaultix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  imports = [ inputs.vaultix.flakeModules.default ];
}
