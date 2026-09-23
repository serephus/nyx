{
  flake-file.inputs = {
    xmmrpc = {
      url = "github:serephus/xmmrpc/rust";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
