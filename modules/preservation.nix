{ den, inputs, ... }: {

  flake-file.inputs.preservation.url = "github:nix-community/preservation";

  den.aspects.preservation = stateless: {
    nixos = {
      imports = [ inputs.preservation.nixosModules.preservation ];
      preservation.enable = stateless;
      preservation.preserveAt."/persist" = {
        # core files to persist
        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
        ];
      };

      preservation.preserveAt."/persist/var" = {
        # core files to persist
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
      #
      # see the firstboot example below for an alternative approach
      systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
    };

    provides.to-users = { user, ... }: {
      nixos = { pkgs, ... }: {
        preservation.preserveAt."/persist/home" = {
          users."${user.userName}" = {
            # my directory habits
            directories = [
              "dev"
              "res"
              {
                directory = ".ssh";
                mode = "0700";
              }
            ];
          };
        };
      };
    };
  };
}
