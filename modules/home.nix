{ den, inputs, ... }: {

  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [ inputs.home-manager.flakeModules.home-manager ];

  den.default.includes = [ den.aspects.home ];

  den.aspects.home = {
    nixos = {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      # some common home manager configs
    };
    homeManager = {
      home.stateVersion = "26.05";
    };
  };
}
