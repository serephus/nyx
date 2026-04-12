{ self, ... }:
{
  # provide a system suitable for laptop
  flake.modules.nixos.laptop = {
    imports = with self.modules.nixos; [
      desktop
    ];
  };
}
