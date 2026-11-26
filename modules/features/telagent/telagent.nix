{ den, inputs, ... }: {
  # Parameterized by the encrypted token file and the user so each host gets a
  # distinct aspect identity (and thus its own bot) even when the same user is
  # on several hosts.
  den.aspects.telagent-bot-token = tokenFile: user: {
    provides.to-hosts.nixos = {
      vaultix.secrets."telagentBotToken-${user}" = {
        file = tokenFile;
        owner = user;
        mode = "0400";
      };
    };
  };

  den.aspects.telagent = tokenFile: {
    provides.to-users = { user, ... }: {
      includes = [
        (den.aspects.telagent-bot-token tokenFile user.userName)
      ];

      nixos = {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [
              ".local/state/telagent"
            ];
          };
        };
      };

      homeManager = { osConfig, ... }: {
        imports = [ inputs.telagent.homeManagerModules.default ];

        services.telagent = {
          enable = true;

          opencode = {
            backend = "v1";
            url = "http://127.0.0.1:4096";
          };

          telegram = {
            botTokenFile = osConfig.vaultix.secrets."telagentBotToken-${user.userName}".path;
            proxy = "http://127.0.0.1:7890";
          };

          notify = {
            onIdle = true;
            onError = true;
            permissions = true;
            questions = true;
            includeLastMessage = true;
            childSessions = false;
          };

          paste = {
            enabled = true;
            thresholdChars = 3900;
          };
        };

        # Keep a persistent opencode server for telagent, and make the normal
        # `opencode` TUI attach to it.
        programs.opencode.web = {
          enable = true;
          extraArgs = [
            "--hostname"
            "127.0.0.1"
            "--port"
            "4096"
          ];
        };

        programs.fish.functions.opencode = ''
          if test (count $argv) -eq 0
              command opencode attach http://127.0.0.1:4096 --dir "$PWD"
          else
              switch $argv[1]
                  case '--help' '-h' '--version' '-v' completion acp mcp attach run debug providers agent upgrade uninstall serve web models stats export import github pr session plugin db
                      command opencode $argv
                  case '-*'
                      command opencode attach http://127.0.0.1:4096 --dir "$PWD" $argv
                  case '*'
                      command opencode attach http://127.0.0.1:4096 --dir "$argv[1]" $argv[2..-1]
              end
          end
        '';
      };
    };
  };
}
