{
  den.aspects.yazi = {
    nixos = {
      programs.yazi.enable = true;
    };
    provides.to-users.homeManager = {
      programs.yazi = {
        enable = true;
        shellWrapperName = "y";
        settings.mgr.show_hidden = true;
      };
    };
  };
}
