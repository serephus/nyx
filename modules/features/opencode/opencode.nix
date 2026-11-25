{ den, ... }: {
  den.aspects.opencode =
    {
      baselineBun ? false,
    }:
    {
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
        homeManager =
          {
            pkgs,
            osConfig,
            lib,
            ...
          }:
          let
            # Bun >= 1.4.0 ships a single Nehalem/SSE4.2 x86_64 binary. Only older
            # bun has a separate -baseline build that avoids AVX2 and runs on
            # pre-Haswell CPUs (e.g. the i5-3427U in the X1 Carbon).
            useBaselineBun =
              baselineBun
              && pkgs.stdenv.hostPlatform.isLinux
              && pkgs.stdenv.hostPlatform.isx86_64
              && lib.versionOlder pkgs.bun.version "1.4.0";

            bun-baseline = pkgs.bun.overrideAttrs (old: {
              pname = "bun-baseline";
              src = pkgs.fetchurl {
                url = "https://github.com/oven-sh/bun/releases/download/bun-v${old.version}/bun-linux-x64-baseline.zip";
                hash = "sha256-nYokKSpwaAkCBdqsCloiP19pc29Sh+N7+I07QDHtx1A=";
              };
              sourceRoot = "bun-linux-x64-baseline";
            });

            opencode-package =
              if useBaselineBun then pkgs.opencode.override { bun = bun-baseline; } else pkgs.opencode;
          in
          {
            programs.opencode = {
              enable = true;
              package = opencode-package;
              extraPackages = [ pkgs.uv ];

              # https://opencode.ai/docs/config/
              settings = {
                shell = "bash";
                autoupdate = false;
                model = "opencode-go/deepseek-v4.1-flash";

                # https://opencode.ai/docs/providers/
                provider = {
                  "opencode-go" = {
                    options = {
                      apiKey = "{file:${osConfig.vaultix.secrets."opencode-go-apikey-${user.userName}".path}}";
                    };
                  };

                  deepseek = {
                    options = {
                      apiKey = "{file:${osConfig.vaultix.secrets."deepseek-apikey-${user.userName}".path}}";
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
