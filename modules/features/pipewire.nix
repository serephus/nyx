{
  den.aspects.pipewire = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.wiremix ];
      services.pipewire = {
        enable = true;
        alsa.enable = true;
      };
    };
  };
}
