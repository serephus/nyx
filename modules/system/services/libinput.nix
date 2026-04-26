{ self, ... }:
{
  flake.modules.nixos.libinput = {
    services.libinput.enable = true;
  };

  flake.modules.nixos.laptop = {
    imports = [
      self.modules.nixos.libinput
    ];
  };
}
