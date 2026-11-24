{ self, inputs, ... }: {
  flake-file.inputs.vaultix = {
    url = "github:milieuim/vaultix";
    inputs = {
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
      pre-commit-hooks.follows = "pre-commit-hooks";
    };
  };

  # vaultix flake-level options
  imports = [ inputs.vaultix.flakeModules.default ];

  # this make it easier to call renc
  # nix run .#seal => nix run .#vaultix.app.<system>.renc
  perSystem = { system, ... }: {
    apps = {
      seal = {
        type = "app";
        meta.description = "Shortcut to re-encrypt all vaultix secrets.";
        program = inputs.self.vaultix.app.${system}.renc;
      };
      edit = {
        type = "app";
        meta.description = "Shortcut to edit the specified vaultix secret.";
        program = inputs.self.vaultix.app.${system}.edit;
      };
    };
  };

  # vaultix flake-level config: identities and node mappings
  flake.vaultix = {
    nodes = {
      # minimal does not have any secrets
      inherit (inputs.self.nixosConfigurations)
        nyx
        x1c
        nova
        vex
        aly
        rpi
        ;
    };
    # YubiKey identity used ONLY for re-encryption (nix run .#seal).
    # Target hosts decrypt with their SSH host key (see the aspect below).
    # This is an age-plugin-yubikey stub, but it still shouldn't be published;
    # rotate it if the repo is ever mirrored.
    identity = ../secrets/age-yubikey-identity-af10df80.txt;
    # backup extra recipients
    extraRecipients = [ "age1yubikey1qgqgeuzz7qak8fxs6nef2nwdznfeyedr5f42htcdpz6j0pjk7vu97mqmcd9" ];
  };

  # parameterized vaultix aspect, takes the public key as parameter
  den.aspects.vaultix = key: {
    nixos = {
      imports = [ inputs.vaultix.nixosModules.default ];
      # vaultix requires userborn or sysusers
      # systemd.sysusers only spawn system users
      services.userborn.enable = true;
      vaultix.settings.hostPubkey = key;
      # pass self here to avoid pass specialArgs
      vaultix.settings.flake = self;
    };
  };
}
