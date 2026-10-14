{ inputs, ... }: {
  # nix run .#vm
  den.aspects.nyx = {
    includes = [
      {
        nixos = { lib, ... }: {
          # Only affects `nix run .#vm` / build-vm, not the real machine.
          virtualisation.vmVariant = {
            users.users.serephus = {
              hashedPasswordFile = lib.mkForce null;
              initialPassword = "serephus";
            };
            users.users.root = {
              hashedPasswordFile = lib.mkForce null;
              initialPassword = "root";
            };
          };
        };
      }
    ];
  };

  perSystem = { pkgs, ... }: {
    packages.vm = pkgs.writeShellApplication {
      name = "vm";
      text =
        let
          host = inputs.self.nixosConfigurations.nyx.config;
        in
        ''
          ${host.system.build.vm}/bin/run-${host.networking.hostName}-vm "$@"
        '';
    };
  };
}
