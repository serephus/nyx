{ inputs, ... }: {
  imports = [
    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
  ];

  # TODO: add secure boot?
  flake-file = {
    # other inputs may be defined at a module using them.
    inputs = {
      den.url = "github:denful/den";
      flake-file.url = "github:vic/flake-file";
    };

    description = "My NixOS configs written from scratch with den.";
  };
}
