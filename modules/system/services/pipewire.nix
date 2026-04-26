{ self, ... }:
{
  flake.modules.nixos.pipewire = {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
    };
  };

  flake.modules.nixos.desktop = {
    imports = [
      self.modules.nixos.pipewire
    ];
  };
}
