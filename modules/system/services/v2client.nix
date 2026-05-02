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

  flake.modules.homeManager.v2client =
    { config, ... }:
    {
      programs.qutebrowser.keyBindings.normal = {
        "<Ctrl-l>" = "config-cycle content.proxy socks5://localhost:1080 none";
        "zz" =
          "hint links spawn yt-dlp -P ${config.home.homeDirectory}/res/downloads --proxy socks5://localhost:1080 {hint-url}";
      };
    };
}
