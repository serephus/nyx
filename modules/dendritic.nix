{ inputs, ... }: {
  imports = [
    (inputs.flake-file.flakeModules.dendritic
      or (throw "flake-file input is missing flakeModules.dendritic"))
    (inputs.den.flakeModules.dendritic
      or (throw "den input is missing flakeModules.dendritic"))
  ];

  flake-file = {
    # other inputs may be defined at a module using them.
    inputs = {
      den.url = "github:denful/den";
      flake-file.url = "github:denful/flake-file";
    };

    description = "My NixOS configs written from scratch with den.";
  };
}
