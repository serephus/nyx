{ den, inputs, ... }: {
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # provides the homeConfigurations output used by the standalone homes in modules/hosts.nix
  imports = [ inputs.home-manager.flakeModules.home-manager ];

  # enable home-manager on every host by default
  den.default.includes = [ den.aspects.home ];

  den.aspects.home = {
    nixos = {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      # this is needed when use global pkgs
      environment.pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];
      # some common home manager configs
      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
        # don't abort activation when an unmanaged dotfile already exists
        backupFileExtension = "hm-backup";
      };
    };
    provides.to-users = { ... }: {
      homeManager = { lib, ... }: {
        home.stateVersion = lib.mkDefault "26.05";
        # let home manager manage itself
        programs.home-manager.enable = true;
      };
    };
  };
}
