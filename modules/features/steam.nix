{ den, ... }: {
  den.aspects.steam = {
    includes = [
      (den.batteries.unfree [
        "steam"
        "steam-unwrapped"
      ])
    ];
    nixos = {
      programs.steam = {
        enable = true;
      };
    };
    provides.to-users = { user, ... }: {
      nixos = {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [
              ".steam"
              ".local/share/Steam"
              ".local/share/steam"
            ];
          };
        };
      };
    };
  };
}
