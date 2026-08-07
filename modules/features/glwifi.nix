{
  den.aspects.wifi = {
    nixos = {
      networking.wireless = {
        enable = true;
        # hashed password should be safe?
        # TODO: maybe we should encrypt psk with vaultix
        # but we have a bootstrap problem here?
        networks."glwifi-5g" = {
          pskRaw = "622d17f9b063286b5324a7e777da9b6f6a46d3aeb7fc64053aae89c98a7cc810";
          priority = 1000;
        };
      };
    };
  };
}
