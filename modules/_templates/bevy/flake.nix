{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      rust-overlay,
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
          nativeBuildInputs = nativeDeps ++ linker;
          buildInputs = [ rust ] ++ deps;
          # xkbcommon use dlopen to load, so we need this envvar in dev shell
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
        };
      }
    );
}
