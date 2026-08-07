{ den, ... }: {
  # Exposes flake apps under the name of each host / home for building with nh.
  # nix run .#nyx, etc
  perSystem = { pkgs, ... }: {
    packages = den.lib.nh.denPackages { fromFlake = true; } pkgs;
  };
}
