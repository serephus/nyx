{
  flake-file.inputs = {
    cocoon = {
      url = "github:serephus/cocoon";
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
