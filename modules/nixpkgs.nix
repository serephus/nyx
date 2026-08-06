{ self, inputs, ... }: {

  flake-file.inputs.nixpkgs = {
    url = "github:nixos/nixpkgs/nixos-26.05";
  };

  den.default.nixos.system.stateVersion = "26.05";
}
