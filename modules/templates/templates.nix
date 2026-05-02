{
  flake.templates = {
    rust = {
      path = ./_rust;
      description = "Rust template, using Naersk";
    };
    typst = {
      path = ./_typst;
      description = "typst template";
    };
  };
}
