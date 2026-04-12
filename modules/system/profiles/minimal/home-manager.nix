{
  # minimal home manager configs
  flake.modules.homeManager.minimal =
    { config, ... }:
    {
      # many home manager configs requires this
      home.homeDirectory = "/home/${config.home.username}";
      # let home manager manage itself
      programs.home-manager.enable = true;
    };
}
