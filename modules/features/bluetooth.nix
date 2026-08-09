{
  den.aspects.bluetooth = {
    nixos = {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
      services.blueman.enable = true;
      preservation.preserveAt."/persist" = {
        directories = [ "/var/lib/bluetooth" ];
      };
    };
  };
}
