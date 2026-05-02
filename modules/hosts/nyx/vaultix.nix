{ self, ... }:
{
  flake.modules.nixos.nyx = {
    imports = [
      self.modules.nixos.vaultix
    ];
    vaultix.settings.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXvckmMZo48If0O1qTTnQRjMeiARAp7sfWNDbX8p6Eu";
  };
}
