# Flake inputs shared by more than one dependency.
#
# cocoon, xmmrpc and lanzaboote each vendor their own copies of the Rust build
# tooling (and git hooks), which would otherwise be locked several times over.
# Promote them to the top level here and let every consumer `follows` a single
# copy, so the lock file only ever contains one node per input.
{
  flake-file.inputs = {
    flake-utils.url = "github:numtide/flake-utils";

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

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
