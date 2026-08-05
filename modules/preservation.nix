{ den, inputs, ... }:
{

  flake-file.inputs.preservation.url = "github:nix-community/preservation";

  den.aspects.preservation = {
    nixos = {
      imports = [ inputs.preservation.nixosModules.preservation ];
      preservation.enable = true;
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
          "/var/lib/systemd/coredump"
          "/var/log"
          {
            directory = "/var/lib/nixos";
            inInitrd = true;
          }
        ];
      };
    };

    provides.to-users =
      { user, ... }:
      {
        nixos =
          { pkgs, ... }:
          {
            preservation.preserveAt."/persist/home" = {
              users."${user.userName}" = {
                # my directory habits
                directories = [
                  "dev"
                  "res"
                  ".local/state/nix"
                  ".cache/nix"
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
