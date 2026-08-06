{ self, inputs, ... }: {

  flake-file.inputs.nixpkgs = {
    url = "github:nixos/nixpkgs/nixos-26.05";
  };
}
