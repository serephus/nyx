{ inputs, lib, ... }:
{
  # Helper functions for creating system / home-manager configurations

  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };

  config.flake.lib = {

    # maps a flake.modules.nixos.<host> to nixosConfigurations.<host>
    mkNixos = system: name: {
      "${name}" = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          inputs.self.modules.nixos."${name}"
          { nixpkgs.hostPlatform = lib.mkDefault system; }
        ];
      };
    };

    # maps a flake.modules.homeManager.<user> to homeConfigurations.<user>
    # for standard alone home manager
    mkHomeManager = system: name: {
      "${name}" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages."${system}";
        modules = [
          inputs.self.modules.homeManager."${name}"
        ];
      };
    };

  };
}
