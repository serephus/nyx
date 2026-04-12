{ self, ... }:
{
  # import the default user
  flake.modules.nixos.nyx = {
    imports = with self.modules.nixos; [
      serephus
    ];
  };
}
