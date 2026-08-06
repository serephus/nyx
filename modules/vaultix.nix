{ self, inputs, ... }: {

  flake-file.inputs.vaultix = {
    url = "github:milieuim/vaultix";
    inputs = {
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
    };
  };

  imports = [ inputs.vaultix.flakeModules.default ];

  # vaultix flake-level config: identities and node mappings
  flake.vaultix = {
    # TODO: filter hosts
    nodes = inputs.self.nixosConfigurations;
    # yubikey identity
    identity = ../secrets/age-yubikey-identity-af10df80.txt;
  };

  den.aspects.vaultix = key: {
    nixos = {
      imports = [ inputs.vaultix.nixosModules.default ];
      # vaultix requires userborn or sysusers
      services.userborn.enable = true;
      vaultix.settings.hostPubkey = key;
      # pass self here to avoid pass specialArgs
      vaultix.settings.flake = self;
    };
  };
}
