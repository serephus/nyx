{ lib, ... }: {
  flake-file.inputs.nixpkgs = {
    url = "github:nixos/nixpkgs/nixos-26.05";
  };

  den.default.nixos.system.stateVersion = lib.mkDefault "26.05";
}
