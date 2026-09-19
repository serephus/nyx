{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixit.url = "github:serephus/nixit";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      rust-overlay,
      nixit,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
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
        linker = pkgs.lib.optionals pkgs.stdenv.isLinux [
          pkgs.clang
          pkgs.mold
        ];

        nativeDeps = [ pkgs.pkg-config ];

        linuxDeps = with pkgs; [
          udev
          alsa-lib
          vulkan-loader
          xorg.libX11
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr # To use the x11 feature
          libxkbcommon
          wayland # To use the wayland feature
        ];

        darwinDeps = [ pkgs.apple-sdk_15 ];

        deps =
          (pkgs.lib.optionals pkgs.stdenv.isLinux linuxDeps)
          ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin darwinDeps);
      in
      {
        devShell = pkgs.mkShell rec {
          name = "bevy";
          nativeBuildInputs = nativeDeps ++ linker;
          buildInputs = [ rust ] ++ deps;
          # xkbcommon use dlopen to load, so we need this envvar in dev shell
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
        };

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
    );
}
