{ den, ... }: {
  den.aspects.opencode = {
    provides.to-users = { user, ... }: {
      includes = [
        (den.aspects.opencode-go-apikey user.userName)
        (den.aspects.deepseek-apikey user.userName)
      ];

      nixos = { user, ... }: {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [
              ".local/share/opencode"
            ];
          };
        };
      };
      homeManager = { pkgs, osConfig, ... }: {
        programs.opencode = {
          enable = true;
          extraPackages = [ pkgs.uv ];

          # https://opencode.ai/docs/config/
          settings = {
            shell = "bash";
            autoupdate = false;
            model = "opencode-go/deepseek-v4.1-flash";

            # https://opencode.ai/docs/providers/
            provider = {
              "opencode-go" = {
                name = "OpenCode Go";
                npm = "@ai-sdk/openai-compatible";
                options = {
                  apiKey = "{file:${osConfig.vaultix.secrets."opencode-go-apikey-${user.userName}".path}}";
                  baseURL = "https://opencode.ai/inference/go/openai/v1";
                };
              };

              deepseek = {
                name = "DeepSeek";
                npm = "@ai-sdk/openai-compatible";
                options = {
                  apiKey = "{file:${osConfig.vaultix.secrets."deepseek-apikey-${user.userName}".path}}";
                  baseURL = "https://api.deepseek.com";
                };
              };
            };

            # LSP is disabled when omitted, so keep this enabled explicitly.
            lsp = true;
          };

          # https://opencode.ai/docs/tui/#configure
          tui.theme = "everforest";

          context = ''
            # Environment

            This machine runs NixOS. Packages and tools are managed by Nix, not
            installed imperatively.

            ## Running commands

            - Do not search `/nix/store`, `/run/current-system`, or other Nix
              paths for binaries, and do not invoke store paths directly.
            - If a command is not on `PATH`, run it through Nix instead:
              - `nix run nixpkgs#<package> -- <args>`
              - `nix shell nixpkgs#<package> -c <command>`
            - For this repository, prefer its flake outputs:
              - `nix develop` for the development shell
              - `nix run .#<app>` for project apps
              - `nix build .#<package>` to build packages
            - If the project has `.envrc`, use `direnv allow` instead of
              manually exporting paths.
            - Add missing dependencies to `flake.nix` or the dev shell instead
              of installing them imperatively.

            ## General

            - Use `nix search nixpkgs <term>` or `nix eval` to find packages
              and versions.
            - Prefer declarative configuration changes over imperative ones.
            - `/nix/store` is read-only; never try to modify it.
          '';
        };
      };
    };
  };
}
