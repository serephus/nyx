{ den, inputs, ... }: {

  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.home = {
    nixos = {
      # imports = [ inputs.preservation.nixosModules.preservation ];
      # preservation.enable = true;
      # preservation.preserveAt."/persist" = {
      #   # core files to persist
      #   directories = [ ];

      #   files = [
      #     {
      #       file = "/etc/machine-id";
      #       inInitrd = true;
      #     }
      #   ];
      # };

      # preservation.preserveAt."/persist/var" = {
      #   # core files to persist
      #   directories = [
      #     "/var/lib/systemd/coredump"
      #     {
      #       directory = "/var/lib/nixos";
      #       inInitrd = true;
      #     }
      #   ];

      #   files = [ ];
      # };
    };

    provides.to-users = { user, ... }: {
      nixos = { pkgs, ... }: {
        # preservation.preserveAt."/persist/home" = {
        #   users."${user.userName}" = {
        #     # my directory habits
        #     directories = [
        #       "dev"
        #       "res"
        #     ];
        #   };
        # };
      };
    };
  };
}
