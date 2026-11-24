{
  flake-file.inputs.telagent = {
    url = "github:serephus/telagent";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
      naersk.follows = "naersk";
      nixit.follows = "nixit";
      rust-overlay.follows = "rust-overlay";
    };
  };
}
