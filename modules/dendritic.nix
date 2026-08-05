{ inputs, ... }:
{
  imports = [
    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
  ];

  flake-file = {
    # other inputs may be defined at a module using them.
    inputs = {
      den.url = "github:denful/den";
      flake-file.url = "github:vic/flake-file";
      nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    };

    description = "NixOS configuration written with den.";
  };
}
