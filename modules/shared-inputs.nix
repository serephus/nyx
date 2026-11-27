# Flake inputs shared by more than one dependency.
#
# cocoon, komi, nixit, truesight, xmmrpc and lanzaboote each vendor their own
# copies of the Rust build tooling (and git hooks), which would otherwise be
# locked several times over. Promote them to the top level here and let every
# consumer `follows` a single copy, so the lock file only ever contains one
# node per input.
{
  flake-file.inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    crate2nix = {
      url = "github:nix-community/crate2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
      inputs.cachix.inputs.nixpkgs.follows = "nixpkgs";
      inputs.cachix.inputs.git-hooks.follows = "pre-commit-hooks";
    };

    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
    };
  };
}
