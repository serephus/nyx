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
      typst = {
        path = ./_templates/typst;
        description = "typst template";
      };
    };
  };
}
