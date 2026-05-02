{ self, ... }:
{
  flake.modules.nixos.v2client =
    { config, ... }:
    {
      imports = with self.modules.nixos; [
        v2ray
      ];
      services.v2ray = {
        enable = true;
        configFile = config.vaultix.templates.v2client.path;
      };
    };
}
