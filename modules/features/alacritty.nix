{
  den.aspects.alacritty = {
    nixos = { pkgs, ... }: {
      fonts = {
        packages = with pkgs; [
          fira-code
          # new way to add nerd fonts
          nerd-fonts.fira-code
          font-awesome
        ];
      };
    };

    provides.to-users.homeManager = { pkgs, lib, ... }: {
      programs.alacritty = {
        enable = true;
        settings = {
          font = {
            size = 20;
            # this font have no korean or japanese variant?
            # set default fonts for alacritty
            normal.family = "FiraCode Nerd Font Mono";
          };
        };
        theme = "gruvbox_dark";
      };

      wayland.windowManager.hyprland.settings."$terminal" =
        lib.mkOverride 100 "${lib.getExe pkgs.alacritty}";
    };
  };
}
