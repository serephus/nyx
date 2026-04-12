{ self, ... }:
{
  # home manager in the same level
  flake.modules.homeManager.desktop = {
    imports = with self.modules.homeManager; [
      basic
    ];
  };
}
