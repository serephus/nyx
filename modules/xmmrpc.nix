{
  flake-file.inputs = {
    xmmrpc = {
      url = "github:serephus/xmmrpc";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixit.follows = "nixit";
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };
  };
}
