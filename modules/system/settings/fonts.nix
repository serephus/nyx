{ self, ... }:
{
  flake.modules.nixos.fonts =
    { pkgs, ... }:
    {
      fonts = {
        # disable default fonts packages because bottom & gnu-freefont issue
        enableDefaultPackages = false;
        # some common font packages
        packages = with pkgs; [
          fira-code
          font-awesome
          # new way to add nerd fonts
          nerd-fonts.fira-code
          noto-fonts
          noto-fonts-color-emoji
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          wqy_microhei
          lxgw-wenkai
        ];
      };
    };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.fonts
    ];
  };

  flake.modules.homeManager.fonts = {
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Noto Serif"
          "Noto Serif CJK SC"
          "Noto Serif CJK TC"
          "Noto Serif CJK JP"
          "Noto Serif CJK KR"
        ];
        sansSerif = [
          "Noto Sans"
          "Noto Sans CJK SC"
          "Noto Sans CJK TC"
          "Noto Sans CJK JP"
          "Noto Sans CJK KR"
        ];
        monospace = [
          "Noto Mono"
          "Sarasa Term SC"
          "Sarasa Term TC"
          "Sarasa Term J"
        ];
        emoji = [
          "Noto Color Emoji"
          "Noto Emoji"
        ];
      };
    };
  };

  flake.modules.homeManager.basic = {
    imports = [
      self.modules.homeManager.fonts
    ];
  };
}
