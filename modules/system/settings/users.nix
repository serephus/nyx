{ self, ... }:
{
  flake.modules.nixos.users = {
    users.mutableUsers = false;
  };

  flake.modules.nixos.minimal = {
    imports = [
      self.modules.nixos.users
    ];
  };
}
