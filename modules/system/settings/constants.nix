{ self, ... }:
{
  # generic constants for any modules
  flake.modules.generic.constants =
    { lib, ... }:
    {
      options.constants = lib.mkOption {
        type = lib.types.attrsOf lib.types.unspecified;
        default = { };
      };

      config.constants = {
        efiMountpoint = "/boot/efi";
      };
    };

  flake.modules.nixos.minimal = {
    imports = [
      self.modules.generic.constants
    ];
  };
}
