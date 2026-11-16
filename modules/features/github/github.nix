{ den, ... }: {
  den.aspects.github = {
    includes = [ den.aspects.github-token ];

    provides.to-users = {
      homeManager = { osConfig, pkgs, ... }: {
        programs.gh = {
          enable = true;
          gitCredentialHelper.enable = true;
          settings = {
            git_protocol = "ssh";
          };
          package = pkgs.writeShellScriptBin "gh" ''
            export GITHUB_TOKEN="$(cat ${osConfig.vaultix.secrets.githubToken.path})"
            exec ${pkgs.gh}/bin/gh "$@"
          '';
        };
      };
    };
  };
}
