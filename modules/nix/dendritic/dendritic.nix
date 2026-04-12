{ inputs, ... }:
{
  # setup of tools for dendritic pattern

  # Simplify Nix Flakes with the module system
  # https://github.com/hercules-ci/flake-parts

  # Generate flake.nix from module options.
  # https://github.com/vic/flake-file

  # Import all nix files in a directory tree.
  # https://github.com/vic/import-tree

  # essential tools for dendritic pattern
  flake-file.inputs = {
    # modular flakes
    flake-parts.url = "github:hercules-ci/flake-parts";
    # auto generate flake.nix
    flake-file.url = "github:vic/flake-file";
    # recursively import a directory
    import-tree.url = "github:vic/import-tree";
  };

  imports = [
    # what this module again?
    inputs.flake-parts.flakeModules.modules
    inputs.flake-file.flakeModules.default
  ];

  # import all modules recursively with import-tree
  flake-file.description = "NixOS configuration written with dendritic pattern.";
  # utilize import-tree here
  flake-file.outputs = ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)
  '';

  # set flake.systems
  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];
}
