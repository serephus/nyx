{ self, ... }:
{
  flake.modules.nixos.root = {
    # default root password
    users.users.root.hashedPassword = "$y$j9T$vmrHUvAuXfmw23ZWlTAFy0$pl4hBYuUzxYPoo7Z3IAPloJ.AZN0jZDeIKgmY/qspf0";
  };

  flake.modules.nixos.minimal = {
    imports = [ self.modules.nixos.root ];
  };
}
