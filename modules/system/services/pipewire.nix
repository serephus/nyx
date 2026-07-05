{ self, ... }:
{
  flake.modules.nixos.pipewire = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.wiremix
    ];
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
