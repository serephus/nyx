{ den, ... }: {
  den.default.includes = [ den.aspects.nix ];
  den.aspects.nix = {
    nixos = {
      nix = {
        channel.enable = false;
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 1w";
        };
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          auto-optimise-store = true;
          trusted-users = [ "@wheel" ];
        };
      };
    };
  };
}
