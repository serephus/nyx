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
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJCl8X5dDv+19y323NZkCbSMiou8phYjbTvTUou5Ju+w i@sereph.us"
          ];
        };
      };

      homeManager."${username}" = {
        imports = with self.modules.homeManager; [
          laptop
          v2client
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
