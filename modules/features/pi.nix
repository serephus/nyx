{
  den.aspects.pi-coding-agent = {
    provides.to-users = { user, ... }: {
      nixos = {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [
              ".pi"
              # for pi memory
              ".local/share/pi"
            ];
          };
        };
      };
    };
  };
}
