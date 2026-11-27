{
  flake-file.inputs = {
    cocoon = {
      url = "github:serephus/cocoon";
      inputs = {
        crate2nix.follows = "crate2nix";
        flake-utils.follows = "flake-utils";
        nixit.follows = "nixit";
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };
  };
}
