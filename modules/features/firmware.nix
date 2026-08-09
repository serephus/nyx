{
  # firmware
  den.aspects.firmware = {
    nixos = {
      hardware.enableRedistributableFirmware = true;
      # enable fwupd to update our firmware
      services.fwupd.enable = true;
      preservation.preserveAt."/persist" = {
        directories = [ "/var/lib/fwupd" ];
      };
    };
  };
}
