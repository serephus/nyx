{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    crate2nix = {
      url = "github:nix-community/crate2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.cachix.inputs.nixpkgs.follows = "nixpkgs";
      inputs.cachix.inputs.git-hooks.inputs.gitignore.follows = "crate2nix/pre-commit-hooks/gitignore";
    };
    nixit = {
      url = "github:serephus/nixit";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.crate2nix.follows = "crate2nix";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      rust-overlay,
      crate2nix,
      nixit,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      githubRepositories.bevy = nixit.lib.githubRepository {
        owner = "serephus";
        name = "bevy";

        description = "description";
        homepage = "homepage";
        topics = [
          "rust"
          "bevy"
        ];
        visibility = "public";

        features = {
          wiki.enable = false;
          issues.enable = true;
          projects.enable = false;
          discussions.enable = false;
        };

        is_template = false;
        is_archived = false;

        pull = {
          merge.enable = true;
          squash.enable = false;
          rebase.enable = false;
          auto_merge = true;
          delete_branch_on_merge = true;
          update_branch = true;
        };

        actions = {
          enable = true;
          policy = "all";
          default_token_permissions = "read";
          allow_pr_approval = false;
        };

        rulesets = {
          default = {
            enforcement = "active";
            conditions.ref_name.include = [ "~DEFAULT_BRANCH" ];
            rules = [
              { type = "deletion"; }
              { type = "non_fast_forward"; }
            ];
          };
          pr = {
            enforcement = "active";
            conditions.ref_name.include = [ "~DEFAULT_BRANCH" ];
            rules = [
              {
                type = "required_status_checks";
                parameters = {
                  do_not_enforce_on_create = true;
                  strict_required_status_checks_policy = true;
                  required_status_checks = [
                    { "context" = "ubuntu-latest-x86_64-unknown-linux-gnu-nightly"; }
                    { "context" = "ubuntu-latest-x86_64-unknown-linux-gnu-stable"; }
                  ];
                };
              }
            ];
          };
        };
      };
    }
    // flake-utils.lib.eachSystem systems (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        rust = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rustfmt"
            "clippy"
            "rust-analyzer"
          ];
          targets = [ "wasm32-unknown-unknown" ];
        };
        linker = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          pkgs.clang
          pkgs.mold
        ];

        nativeDeps = [ pkgs.pkg-config ];

        linuxDeps = with pkgs; [
          udev
          alsa-lib
          vulkan-loader
          libX11
          libXcursor
          libXi
          libXrandr # To use the x11 feature
          libxkbcommon
          wayland # To use the wayland feature
        ];

        darwinDeps = [ pkgs.apple-sdk_15 ];

        deps =
          (pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux linuxDeps)
          ++ (pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin darwinDeps);

        cargoNix = pkgs.callPackage (crate2nix.tools.${system}.generatedCargoNix {
          name = "bevy-app";
          src = ./.;
        }) {
          buildRustCrateForPkgs = pkgs': pkgs'.buildRustCrate.override {
            defaultCrateOverrides = pkgs'.defaultCrateOverrides // {
              wayland-sys = attrs: {
                nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ [ pkgs'.pkg-config ];
                buildInputs = (attrs.buildInputs or [ ]) ++ [ pkgs'.wayland ];
              };
            };
          };
        };
      in
      {
        packages.default = cargoNix.rootCrate.build;
        devShell = pkgs.mkShell rec {
          name = "bevy";
          nativeBuildInputs = nativeDeps ++ linker;
          buildInputs = [ rust ] ++ deps;
          # xkbcommon use dlopen to load, so we need this envvar in dev shell
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
        };
      }
    );
}
