{ self, ... }:
{
  # nyx should have corresponding home-manager profile
  flake.modules.homeManager.nyx = {
    imports = with self.modules.homeManager; [
      laptop
    ];
  };
}
