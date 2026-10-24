{
  flake-file.inputs = {
    komi = {
      url = "github:serephus/komi";
      inputs = {
        flake-utils.follows = "flake-utils";
        naersk.follows = "naersk";
        nixit.follows = "nixit";
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };
  };
}
