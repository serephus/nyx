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
                __nyx_cwd_color = ''
                  function __nyx_cwd_color
                      if not command -q sha256sum
                          set_color $fish_color_cwd
                          return
                      end

                      set -l pairs (pwd -P | sha256sum | string sub -l 6 | string match -ra ..)
                      set -l channels
                      for pair in $pairs
                          set -a channels (math --base=hex "min(255, 0x$pair + 0x30)")
                      end

                      set -l color (string replace -a 0x "" -- $channels | string pad -c 0 -w 2 | string join "")
                      set_color $color
                  end
                '';

                fish_prompt = ''
                  function fish_prompt
                      set -l last_status $status
                      set -l normal (set_color normal)
                      set -l delim "> "

                      fish_is_root_user; and set delim "#"

                      set -l host
                      if set -q SSH_TTY
                          or begin
                              command -sq systemd-detect-virt
                              and systemd-detect-virt -q
                          end
                          set host (string join "" (set_color $fish_color_user) "$USER" $normal "@" (set_color $fish_color_host) (hostname) $normal ":")
                      end

                      set -l status_marker
                      if test $last_status -ne 0
                          set status_marker (set_color $fish_color_error)"[$last_status]"$normal
                      end

                      echo -n -s $host (__nyx_cwd_color)(prompt_pwd) $normal $status_marker $delim
                  end
                '';

                fish_right_prompt = ''
                  function fish_right_prompt
                      set -l parts

                      if set -q VIRTUAL_ENV
                          set -a parts (string replace -r '.*/' "" -- "$VIRTUAL_ENV")
                      end

                      if set -q cmd_duration; and test "$cmd_duration" -gt 100
                          set -a parts (math "$cmd_duration" / 1000)"s"
                      end

                      set -a parts (fish_vcs_prompt 2>/dev/null)
                      set -a parts (set_color brgrey)(date "+%R")(set_color normal)

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
