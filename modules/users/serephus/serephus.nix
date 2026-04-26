{ lib, self, ... }:
let
  username = "serephus";
in
{
  flake.modules = lib.mkMerge [
    (self.factory.user username true)
    {
      nixos."${username}" = _: {
        users.users."${username}" = {
          hashedPassword = "$y$j9T$Kd.XCW/gJoS41OmyJioSe1$MAk45.m/HFOYdo4WcIPlDz4X9ipmzgv3aWbRqIEaJ89";
        };
      };

      homeManager."${username}" = {
        imports = with self.modules.homeManager; [
          laptop
        ];

        # per user specific settings goes here
        programs.git.settings.user = {
          name = "${username}";
          email = "i@sereph.us";
        };
      };
    }
  ];
}
