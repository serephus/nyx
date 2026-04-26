{ self, ... }:
{
  flake.modules.nixos.tmux = {
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      keyMode = "vi";
    };
  };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.tmux
    ];
  };

  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        shell = "${pkgs.fish}/bin/fish";
        baseIndex = 1;
        keyMode = "vi";
        prefix = "C-a";
      };
    };

  flake.modules.homeManager.basic = {
    imports = [
      self.modules.homeManager.tmux
    ];
  };
}
