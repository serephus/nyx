{
  den.aspects.yubikey = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.yubikey-manager
        pkgs.age-plugin-yubikey
      ];
      services.pcscd.enable = true;
    };
  };
}
