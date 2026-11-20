{
  den.aspects.helix = {
    nixos = { pkgs, ... }: {
      # Root gets its own helix; regular users get it from home-manager.
      users.users.root.packages = [
        pkgs.helix
      ];
    };

    provides.to-users.homeManager = {
      programs.helix = {
        enable = true;
        defaultEditor = true;
        settings = {
          theme = "gruvbox-material";
          editor = {
            text-width = 100;
            soft-wrap = {
              enable = true;
              wrap-at-text-width = true;
            };
            line-number = "relative";
            rulers = [ 100 ];
            lsp = {
              display-messages = true;
              display-inlay-hints = true;
            };
            file-picker.hidden = false;
          };
          keys.normal = {
            space = {
              space = "file_picker";
              w = ":w";
              q = ":q";
            };
            esc = [
              "collapse_selection"
              "keep_primary_selection"
            ];
            # tries to use gw more
            ret = "goto_word";
          };
        };
        languages = {
          language = [
            {
              name = "python";
              language-servers = [
                "pyright"
                "ruff"
              ];
              auto-format = true;
              formatter = {
                command = "black";
                args = [
                  "-"
                  "--quiet"
                  "--line-length=80"
                ];
              };
            }
            {
              name = "nix";
              auto-format = true;
              formatter.command = "nixfmt";
            }
          ];
          language-server = {
            rust-analyzer.config = {
              check.command = "clippy";
              inlayHints.bindingModeHints.enable = true;
            };
            pyright = {
              command = "basedpyright-langserver";
              args = [ "--stdio" ];
              config.python.analysis = {
                reportMissingTypeStubs = false;
                typeCheckingMode = "basic";
                autoImportCompletions = true;
              };
            };
            ruff = {
              command = "ruff";
              config.settings.args = [ ];
            };
          };
        };
      };
    };
  };
}
