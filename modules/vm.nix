{ inputs, ... }: {
  # `nix run .#vm`: boot the nyx host in a VM with throwaway credentials.
  # Extending the nyx aspect from here keeps the VM-only overrides out of the
  # real machine config.
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
      meta.description = "Run the nyx host configuration in a VM";
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
