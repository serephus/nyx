{ den, ... }: {
  den.aspects.wifi = {
    nixos = {
      networking.wireless = {
        enable = true;
        # hashed password should be safe?
        networks."glwifi-5g" = {
          pskRaw = "513ce170f82b9f9bba9a5a9ddc5db9a62a26903dc9eaed7e9059502c6169440a";
          priority = 1000;
        };
      };
    };
  };
}
