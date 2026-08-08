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
      boot.loader.systemd-boot.enable = lib.mkForce (!secureboot);

      boot.lanzaboote = {
        enable = secureboot;
        pkiBundle = "/var/lib/sbctl";
        # TODO: use yubikey once lanzaboote supported?
        autoGenerateKeys.enable = true;
        autoEnrollKeys = {
          autoReboot = true;
          enable = true;
        };
      };

      preservation.preserveAt."/persist/var" = {
        directories = [ "/var/lib/sbctl" ];
      };
    };
  };
}
