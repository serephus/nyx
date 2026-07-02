{ self, ... }:
{
  flake.vaultix = {
    # vaultix configs
    nodes = self.outputs.nixosConfigurations;
    # identity = "./secrets/key.txt";
    identity = "./secrets/age-yubikey-identity-af10df80.txt";
  };
}
