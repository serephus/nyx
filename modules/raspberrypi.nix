{
  flake-file.inputs = {
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      # the Pi host is built from the same nixpkgs as every other host
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };
  };

  # Binary cache for the RPi kernel/firmware. It is keyed to the nixpkgs
  # revision upstream locked, so following our nixpkgs may cause local
  # rebuilds; it is still useful for packages that happen to match.
  flake-file.nixConfig = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };
}
