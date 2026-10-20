{
  den.aspects.cargo = {
    provides.to-users = { user, ... }: {
      nixos = {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [ ".cargo" ];
          };
        };
      };
    };
  };
}
