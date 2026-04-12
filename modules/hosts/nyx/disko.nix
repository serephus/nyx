{ self, ... }:
{
  # import disko nixosModule and predefined disk nvme0n1
  flake.modules.nixos.nyx = {
    imports = with self.modules.nixos; [
      disko
      nvme0n1
    ];
  };
}
