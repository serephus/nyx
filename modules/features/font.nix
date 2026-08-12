{
  den.aspects.font = {
    nixos = { pkgs, ... }: {
      fonts = {
        # disable default fonts packages because bottom & gnu-freefont issue
        enableDefaultPackages = false;
        # some common font packages
        packages = with pkgs; [
          noto-fonts
          noto-fonts-color-emoji
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          wqy_microhei
          lxgw-wenkai
        ];
      };
    };
    provides.to-users.homeManager = {
      fonts.fontconfig = {
        enable = true;
        # match chinese variant first
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
  };
}
