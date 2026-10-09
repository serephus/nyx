{
  flake = {
    templates = {
      rust = {
        path = ./_templates/rust;
        description = "Rust template, using Naersk";
      };
      bevy = {
        path = ./_templates/bevy;
        description = "Bevy template";
      };
      python = {
        path = ./_templates/python;
        description = "Python template";
      };
      cpp = {
        path = ./_templates/cpp;
        description = "C++ template with CMake";
      };
      koka = {
        path = ./_templates/koka;
        description = "Koka template";
      };
      haskell = {
        path = ./_templates/haskell;
        description = "Haskell template with Cabal";
      };
      zig = {
        path = ./_templates/zig;
        description = "Zig template";
      };
      typst = {
        path = ./_templates/typst;
        description = "typst template";
      };
    };
  };
}
