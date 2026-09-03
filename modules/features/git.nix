{
  den.aspects.git =
    let
      gitFishAbbrs = {
        ga = "git add";
        gs = "git status";
        gc = "git checkout";
        gcl = "git clone";
        gm = "git commit";
        gps = "git push";
        gpl = "git pull";
        gr = "git rebase";
        gri = "git rebase -i";
        gt = "git tag";
        gma = "git commit --amend";
        gw = "git worktree";
        gwa = "git worktree add";
        gra = "git rebase --abort";
        grc = "git rebase --continue";
        gcp = "git cherry-pick";
        gcpa = "git cherry-pick --abort";
        gcpc = "git cherry-pick --continue";
      };
    in
    {
      nixos = {
        programs = {
          # we only use minimal configs for root user
          git = {
            enable = true;
            config.init.defaultBranch = "main";
          };
          fish.shellAbbrs = gitFishAbbrs;
        };
      };

      provides.to-users.homeManager = { lib, ... }: {
        programs = {
          git = {
            enable = true;
            settings = {
              alias = {
                # some of my defined git alias
                lines = "! git log --author=\"$1\" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf \"added lines: %s, removed lines: %s, total lines: %s\\n\", add, subs, loc }' #";
                lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
                la = "log --color --graph --all --branches";
              };
              init.defaultBranch = "main";
              # let use pull --ff-only
              pull.ff = "only";
              merge.ff = "only";
              fetch.prune = true;
            };
          };
          # add git alias to fish
          fish.shellAbbrs = gitFishAbbrs;

          # add git blame shortcut to helix
          helix.settings.keys.normal.space.i =
            lib.mkForce ":sh git blame -L %{cursor_line},%{cursor_line} %{buffer_name}";
        };
      };
    };
}
