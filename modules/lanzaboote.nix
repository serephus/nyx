{ lib, inputs, ... }: {
  flake-file.inputs.lanzaboote = {
    url = "github:nix-community/lanzaboote";
    inputs = {
      crane.follows = "vaultix/crane";
      nixpkgs.follows = "nixpkgs";
      pre-commit.follows = "pre-commit-hooks";
      rust-overlay.follows = "rust-overlay";
    };
  };

  den.aspects.lanzaboote =
    {
      secureboot ? true,
      autoReboot ? true,
    }:
    {
      nixos = { pkgs, config, ... }: {
        imports = [
          inputs.lanzaboote.nixosModules.lanzaboote
          # make sure the preservation option exists for the pkiBundle below
          inputs.preservation.nixosModules.preservation
        ];

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
          configurationLimit = 8;
          # with these options we only need minimal intervention
          autoGenerateKeys.enable = true;
          autoEnrollKeys = {
            inherit autoReboot;
            enable = true;
          };
        };

        preservation.preserveAt."/persist" = {
          directories = [ config.boot.lanzaboote.pkiBundle ];
        };
      };
    };
}
