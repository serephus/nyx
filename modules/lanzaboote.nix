{ lib, inputs, ... }: {
  flake-file.inputs.lanzaboote = {
    url = "github:nix-community/lanzaboote";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.crane.follows = "vaultix/crane";
  };

  den.aspects.lanzaboote = secureboot: {
    nixos = { pkgs, config, ... }: {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      environment.systemPackages = [
        # For debugging and troubleshooting Secure Boot.
        pkgs.sbctl
      ];

      # Lanzaboote currently replaces the systemd-boot module.
      boot.loader.systemd-boot.enable = lib.mkForce (!secureboot);

      # TODO: use yubikey once lanzaboote supported?
      boot.lanzaboote = {
        enable = secureboot;
        pkiBundle = "/var/lib/sbctl";
        # with these options we only need minimal intervention
        autoGenerateKeys.enable = true;
        autoEnrollKeys = {
          autoReboot = true;
          enable = true;
        };
      };

      preservation.preserveAt."/persist" = {
        directories = [ config.boot.lanzaboote.pkiBundle ];
      };
    };
  };
}
