{
  den.aspects.greet.nixos = {
    services.greetd.enable = true;
    programs.regreet.enable = true;
    programs.uwsm.enable = true;
  };
}
