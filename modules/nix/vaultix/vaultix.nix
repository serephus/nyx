{ self, ... }:
{
  flake.vaultix = {
    # vaultix configs
    nodes = self.outputs.nixosConfigurations;
    identity = "./secrets/key.txt";
  };
}
