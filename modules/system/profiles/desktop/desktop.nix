{ self, ... }:
{
  # provide a gui system with window manager
  flake.modules.nixos.desktop = {
    imports = with self.modules.nixos; [
      basic
    ];
  };
}
