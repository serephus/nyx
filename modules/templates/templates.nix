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
    bevy = {
      path = ./_bevy;
      description = "Bevy template";
    };
    python = {
      path = ./_python;
      description = "Python template";
    };
  };
}
