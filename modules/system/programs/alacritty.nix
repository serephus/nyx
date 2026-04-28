{ self, ... }:
{
  flake.modules.nixos.alacritty =
    { pkgs, ... }:
    {
      fonts = {
        packages = with pkgs; [
          fira-code
          # new way to add nerd fonts
          nerd-fonts.fira-code
          font-awesome
        ];
      };
    };

  flake.modules.nixos.desktop = {
    imports = [
      self.modules.nixos.alacritty
    ];
  };

  flake.modules.homeManager.alacritty =
    { pkgs, lib, ... }:
    {
      programs.alacritty = {
        enable = true;
        # this font have no korean or japanese variant?
        # set default fonts for alacritty
        settings.font.normal.family = "FiraCode Nerd Font Mono";
      };

      wayland.windowManager.hyprland.settings."$terminal" =
        lib.mkOverride 100 "${lib.getExe pkgs.alacritty}";
    };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.alacritty
    ];
  };
}
