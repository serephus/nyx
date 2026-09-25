# DO-NOT-EDIT. This file was auto-generated using github:denful/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "My NixOS configs written from scratch with den.";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    cocoon = {
      url = "github:serephus/cocoon";
      inputs = {
        flake-utils.follows = "flake-utils";
        naersk.follows = "naersk";
        nixit.follows = "nixit";
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };
    den.url = "github:denful/den";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-file.url = "github:denful/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:denful/import-tree";
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        crane.follows = "vaultix/crane";
        nixpkgs.follows = "nixpkgs";
        pre-commit.follows = "pre-commit-hooks";
        rust-overlay.follows = "rust-overlay";
      };
    };
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixit = {
      url = "github:serephus/nixit";
      inputs = {
        flake-utils.follows = "flake-utils";
        naersk.follows = "naersk";
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation.url = "github:nix-community/preservation";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vaultix = {
      url = "github:milieuim/vaultix";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
    };
    wallpaper = {
      url = "github:serephus/wallpaper";
      flake = false;
    };
    xmmrpc = {
      url = "github:serephus/xmmrpc/rust";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixit.follows = "nixit";
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };
  };
}
