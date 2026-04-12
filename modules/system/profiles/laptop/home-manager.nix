{ self, ... }:
{
  # provide a system suitable for laptop
  flake.modules.homeManager.laptop = {
    imports = with self.modules.homeManager; [
      desktop
    ];
  };
}
