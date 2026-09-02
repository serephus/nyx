{
  den.aspects.logind = {
    nixos = {
      services.logind = {
        enable = true;
        settings.Login = {
          HandleLidSwitch = "ignore";
        };
      };
    };
  };
}
