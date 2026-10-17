{
  flake-file.inputs = {
    truesight = {
      url = "github:serephus/truesight";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixit.follows = "nixit";
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
        naersk.follows = "naersk";
      };
    };
  };
}
