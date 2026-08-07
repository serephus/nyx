{ den, inputs, ... }: {
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # TODO: what does it do?
  imports = [ inputs.home-manager.flakeModules.home-manager ];

  # do we want hm everywhere?
  den.default.includes = [ den.aspects.home ];

  den.aspects.home = {
    nixos = {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      # some common home manager configs
      home-manager = {
        verbose = true;
        useUserPackages = true;
        useGlobalPkgs = true;
      };
    };
    provides.to-users = { user, ... }: {
      homeManager = { lib, ... }: {
        home.stateVersion = lib.mkDefault "26.05";
        # many home manager configs requires this
        home.homeDirectory = "/home/${user.userName}";
        # let home manager manage itself
        programs.home-manager.enable = true;
      };
    };
  };
}
