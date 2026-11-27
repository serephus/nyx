{
  flake-file.inputs.telagent = {
    url = "github:serephus/telagent";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
      crate2nix.follows = "crate2nix";
      nixit.follows = "nixit";
      rust-overlay.follows = "rust-overlay";
    };
  };
}
