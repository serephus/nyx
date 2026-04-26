{ self, ... }:
{
  flake.modules.nixos.git = {
    programs = {
      git = {
        enable = true;
        config.init.defaultBranch = "main";
      };
      fish.shellAbbrs = {
        ga = "git add";
        gs = "git status";
        gc = "git checkout";
        gcl = "git clone";
        gm = "git commit";
      };
    };
  };

  flake.modules.nixos.basic = {
    imports = [
      self.modules.nixos.git
    ];
  };

  flake.modules.homeManager.git =
    { lib, ... }:
    {
      programs = {
        git = {
          enable = true;
          settings = {
            alias = {
              count-lines = "! git log --author=\"$1\" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf \"added lines: %s, removed lines: %s, total lines: %s\\n\", add, subs, loc }' #";
              lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
            };
            init.defaultBranch = "main";
          };
        };
        fish.shellAbbrs = {
          ga = "git add";
          gs = "git status";
          gc = "git checkout";
          gcl = "git clone";
          gm = "git commit";
        };

        helix.settings.keys.normal.space.i =
          lib.mkForce ":sh git blame -L %{cursor_line},%{cursor_line} %{buffer_name}";
      };
    };

  flake.modules.homeManager.basic = {
    imports = [
      self.modules.homeManager.git
    ];
  };
}
