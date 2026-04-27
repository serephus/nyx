{ self, ... }:
{
  flake.modules.nixos.regreet = {
    imports = with self.modules.nixos; [
      greetd
    ];
    programs.regreet.enable = true;
  };

  flake.modules.nixos.hyprland = {
    imports = [
      self.modules.nixos.regreet
    ];
  };
}
