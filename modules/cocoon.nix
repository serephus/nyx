{
  flake-file.inputs = {
    cocoon = {
      url = "github:serephus/cocoon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
