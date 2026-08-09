{
  den.aspects.yubikey = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.yubikey-manager
        pkgs.age-plugin-yubikey
      ];
      services.udev.packages = [ pkgs.yubikey-personalization ];
      services.pcscd.enable = true;
    };
  };
}
