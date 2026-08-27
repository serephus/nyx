{
  den.aspects.fish =
    let
      # Shared by both the NixOS and home-manager fish configs.
      shellAbbrs = {
        pb = "curl -F 'c=@-' 'https://fars.ee'";
        cargo-git = "cargo --config net.git-fetch-with-cli=true ";
      };
      interactiveShellInit = ''
        set -g fish_greeting
        set -g fish_key_bindings fish_vi_key_bindings
        set -g VIRTUAL_ENV_DISABLE_PROMPT true

        set -g __fish_git_prompt_showdirtystate 1
        set -g __fish_git_prompt_showuntrackedfiles 1
        set -g __fish_git_prompt_showupstream informative
        set -g __fish_git_prompt_showcolorhints 1
        set -g __fish_git_prompt_use_informative_chars 1
        set -g __fish_git_prompt_char_untrackedfiles '?'

        if string match -qi '*.utf-8' -- $LANG $LC_CTYPE $LC_ALL
            set -g __fish_git_prompt_char_dirtystate \U1F4A9
        else
            set -g __fish_git_prompt_char_dirtystate '+'
        end

        # Gruvbox colors (dark).
        set -g fish_color_normal ebdbb2
        set -g fish_color_command b8bb26
        set -g fish_color_param ebdbb2
        set -g fish_color_error fb4934
        set -g fish_color_quote b8bb26
        set -g fish_color_redirection fabd2f
        set -g fish_color_end fabd2f
        set -g fish_color_operator fe8019
        set -g fish_color_escape fe8019
        set -g fish_color_comment 928374
        set -g fish_color_autosuggestion 928374
        set -g fish_color_selection --background=3c3836 ebdbb2
        set -g fish_color_search_match --background=d79921 282828
        set -g fish_color_user b8bb26
        set -g fish_color_host 83a598
        set -g fish_color_cwd 458588
        set -g fish_color_cwd_root fb4934
        set -g fish_color_valid_path --underline

        # Completion menu (pager) colors.
        set -g fish_pager_color_prefix 83a598
        set -g fish_pager_color_completion ebdbb2
        set -g fish_pager_color_description 928374
        set -g fish_pager_color_progress 928374
        set -g fish_pager_color_selected_completion --background=3c3836 ebdbb2
      '';
    in
    {
      nixos = {
        programs.fish = {
          enable = true;
          inherit shellAbbrs interactiveShellInit;
        };
      };

      provides.to-users = { user, ... }: {
        nixos = {
          preservation.preserveAt."/persist" = {
            users."${user.userName}" = {
              files = [
                {
                  file = ".local/share/fish/fish_history";
                  # fix renaming file error
                  how = "symlink";
                }
              ];
            };
          };
        };

        homeManager = { lib, pkgs, ... }: {
          programs = {
            fish = {
              enable = true;
              inherit shellAbbrs interactiveShellInit;

              functions = {
                __nyx_git_branch = ''
                  function __nyx_git_branch
                      set -l branch (git symbolic-ref -q --short HEAD 2>/dev/null)
                      if test -z "$branch"
                          set branch (git rev-parse --short HEAD 2>/dev/null)
                      end
                      if test -n "$branch"
                          set_color fabd2f
                          echo -n "[$branch]"
                          set_color normal
                      end
                  end
                '';

                __nyx_git_status = ''
                  function __nyx_git_status
                      # fish_git_prompt prints (branch|status...) — keep only the status part,
                      # the branch is already shown on the left prompt.
                      set -l vcs (fish_git_prompt 2>/dev/null)
                      string match -q '*|*' -- $vcs; or return

                      string replace -r '^ *\([^|]*\|' "" -- $vcs | string trim -c ')'
                  end
                '';

                fish_prompt = ''
                  function fish_prompt
                      set -g __nyx_last_status $status

                      set -l parts

                      # env-ctx: python venv / nix-shell
                      if set -q VIRTUAL_ENV
                          set -a parts (set_color b8bb26)"("(string replace -r '.*/' "" -- "$VIRTUAL_ENV")")"(set_color normal)
                      end
                      if set -q IN_NIX_SHELL
                          set -a parts (set_color fe8019)"(nix)"(set_color normal)
                      end

                      # abbr-pwd
                      set -a parts (set_color $fish_color_cwd)(prompt_pwd)(set_color normal)

                      # git-branch
                      set -l branch (__nyx_git_branch)
                      if test -n "$branch"
                          set -a parts $branch
                      end

                      # prompt-sym
                      if fish_is_root_user
                          set -a parts (set_color fb4934)'# '(set_color normal)
                      else
                          set -a parts '> '
                      end

                      string join " " -- $parts
                  end
                '';

                fish_right_prompt = ''
                  function fish_right_prompt
                      set -l parts

                      # exit-code
                      if set -q __nyx_last_status; and test $__nyx_last_status -ne 0
                          set -a parts (set_color fb4934)"[$__nyx_last_status]"(set_color normal)
                      end

                      # time-elapsed
                      if set -q CMD_DURATION; and test "$CMD_DURATION" -gt 100
                          set -a parts (set_color 928374)(math "$CMD_DURATION" / 1000)"s"(set_color normal)
                      end

                      # git-status (branch-free, branch lives on the left prompt)
                      set -l git_status (__nyx_git_status)
                      if test -n "$git_status"
                          set -a parts $git_status
                      end

                      # identity, only when relevant (ssh / vm)
                      if set -q SSH_TTY
                          or begin
                              command -sq systemd-detect-virt
                              and systemd-detect-virt -q
                          end
                          set -a parts (set_color $fish_color_user)"$USER"(set_color normal)"@"(set_color $fish_color_host)(hostname)(set_color normal)
                      end

                      set_color reset
                      string join " " -- $parts
                  end
                '';
              };
            };

            alacritty.settings.terminal.shell = lib.mkForce "fish";
            tmux.shell = lib.getExe pkgs.fish;
          };
        };
      };
    };
}
