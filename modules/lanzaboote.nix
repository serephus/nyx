{ inputs, ... }: {
  flake-file.inputs.lanzaboote = {
    url = "github:nix-community/lanzaboote";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.crane.follows = "vaultix/crane";
  };

  den.aspects.lanzaboote = secureboot: {
    nixos = { lib, pkgs, ... }: {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];
      environment.systemPackages = [
        # For debugging and troubleshooting Secure Boot.
        pkgs.sbctl
      ];

      # Lanzaboote currently replaces the systemd-boot module.
      # This setting is usually set to true in configuration.nix
      # generated at installation time. So we force it to false
      # for now.
      boot.loader.systemd-boot.enable = lib.mkForce (!secureboot);

      boot.lanzaboote = {
        enable = secureboot;
        pkiBundle = "/var/lib/sbctl";
      };

      preservation.preserveAt."/persist/var" = {
        # core files to persist
        directories = [
          {
            directory = "/var/lib/sbctl";
            inInitrd = true;
          }
        ];
      };
    };
  };
}
