{
  flake = {
    templates = {
      android = {
        path = ./_templates/android;
        description = "Android template with Kotlin, Jetpack Compose and Gradle";
      };
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
      idris2 = {
        path = ./_templates/idris2;
        description = "Idris2 template";
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
