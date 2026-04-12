{ inputs, ... }:
{
  # this is where homeConfigurations generated
  flake.homeConfigurations = inputs.self.lib.mkHomeManager "x86_64-linux" "serephus";
}
