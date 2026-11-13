{
  den.aspects.opencode = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.opencode
      ];
    };
    provides.to-users = {
      nixos = { user, ... }: {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [
              ".local/share/opencode"
              ".config/opencode"
            ];
          };
        };
      };
    };
  };
}
