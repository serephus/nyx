{ self, ... }:
{
  flake.modules.homeManager.fcitx5 =
    { pkgs, ... }:
    let
      customShuangpinProfile = {
        "方案" = {
          "方案名称" = "custom";
        };
        "零声母标识" = {
          "" = "O";
        };
        "声母" = {
          # 双拼编码就是它本身的声母不必列出
          ch = "I";
          sh = "U";
          zh = "V";
        };

        "韵母" = {
          # 双拼编码就是它本身的韵母不必列出
          ai = "D";
          an = "N";
          ang = "Y";
          ao = "C";
          ei = "W";
          en = "T";
          eng = "G";
          er = "R";
          ia = "X";
          ian = "M";
          iang = "L";
          iao = "B";
          ie = "H";
          "in" = "P";
          ing = "F";
          iong = "S";
          iu = "Q";
          ong = "S";
          ou = "Z";
          ua = "X";
          uai = "F";
          uan = "R";
          uang = "L";
          ue = "K";
          ui = "V";
          un = "J";
          uo = "O";
        };
      };
      generatedDat = (pkgs.formats.ini { }).generate "sp.dat" customShuangpinProfile;
    in
    {
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          # ignoreUserConfig = true;
          addons = [
            pkgs.fcitx5-gtk
            pkgs.qt6Packages.fcitx5-chinese-addons
            pkgs.fcitx5-pinyin-zhwiki
            pkgs.fcitx5-tokyonight
            pkgs.libsForQt5.fcitx5-qt
          ];
          waylandFrontend = true;
          settings = {
            # TODO: add more settings
            globalOptions = { };
            inputMethod = {
              "Groups/0" = {
                "Name" = "Default";
                "Default Layout" = "us";
                "DefaultIM" = "shuangpin";
              };
              "Groups/0/Items/0" = {
                "Name" = "keyboard-us";
                "Layout" = "";
              };
              "Groups/0/Items/1" = {
                "Name" = "shuangpin";
                "Layout" = "";
              };
              "GroupOrder" = {
                "0" = "Default";
              };
            };
            addons = {
              pinyin = {
                globalSection = {
                  # pinyin only support one custom profile
                  # it's name is fixed "custom"
                  ShuangpinProfile = "custom";
                  ShuangpinMode = true;
                  PageSize = 7;
                };
                sections = { };
              };
            };
          };
        };
      };
      xdg.configFile."fcitx5/pinyin/sp.dat".source = generatedDat;
      xdg.configFile."fcitx5".recursive = true;
    };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.fcitx5
    ];
  };
}
