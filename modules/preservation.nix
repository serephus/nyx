{ inputs, ... }: {
  flake-file.inputs.preservation.url = "github:nix-community/preservation";

  den.aspects.preservation = stateless: {
    nixos = { lib, ... }: {
      imports = [ inputs.preservation.nixosModules.preservation ];
      preservation.enable = stateless;
      preservation.preserveAt."/persist" = {
        files = [
          {
            # must preserve for various services
            file = "/etc/machine-id";
            inInitrd = true;
          }
        ];
        directories = [
          "/var/log"
          {
            directory = "/var/lib/nixos";
            inInitrd = true;
          }
        ];
      };

      # systemd-machine-id-commit.service would fail, but it is not relevant
      # in this specific setup for a persistent machine-id so we disable it
      # see the firstboot example below for an alternative approach
      systemd.suppressedSystemUnits = lib.optional stateless "systemd-machine-id-commit.service";
    };

    provides.to-users = { user, ... }: {
      nixos = {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            # my directory habits
            # TODO: maybe add bash history here?
            directories = [
              "dev"
              "res"
            ];
          };
        };
      };
    };
  };
}
