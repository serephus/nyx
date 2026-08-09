{ den, ... }: {
  den.default.includes = [ den.aspects.nix ];
  den.aspects.nix = {
    nixos = {
      nix = {
        # as stateless as possible
        channel.enable = false;
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 1w";
        };
        settings = {
          # why not?
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          auto-optimise-store = true;
          # root is trusted by default
          trusted-users = [ "@wheel" ];
        };
      };
    };
  };
}
