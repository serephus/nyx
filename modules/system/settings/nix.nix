{ self, ... }:
{
  flake.modules.nixos.nix = {
    nix = {
      channel.enable = false;
      # auto gc
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 1w";
      };
      settings = {
        # do we want pipe-operators
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
        trusted-users = [
          # "root" root is trusted by default
          "@wheel"
        ];
      };
    };
  };

  flake.modules.nixos.minimal = {
    imports = [ self.modules.nixos.nix ];
  };
}
