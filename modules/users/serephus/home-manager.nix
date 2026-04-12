let
  username = "serephus";
in
{
  # we only want basic standard alone home manager configs
  flake.modules.homeManager."${username}" = {
    home.username = "${username}";
    home.stateVersion = "25.11";
  };
}
