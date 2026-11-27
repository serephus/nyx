{
  flake-file.inputs = {
    komi = {
      url = "github:serephus/komi";
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
