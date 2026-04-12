{
  # we now have nothing here
  flake.modules.nixos.minimal = {
    # we want en utf-8
    i18n.defaultLocale = "en_US.UTF-8";
  };
}
