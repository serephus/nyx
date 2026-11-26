{ den, ... }: {
  den.aspects.github = {
    provides.to-users = { user, ... }: {
      includes = [ (den.aspects.github-token user.userName) ];

      homeManager = { osConfig, pkgs, ... }: {
        programs.gh = {
          enable = true;
          gitCredentialHelper.enable = true;
          settings = {
            git_protocol = "https";
          };
          package = pkgs.writeShellScriptBin "gh" ''
            export GITHUB_TOKEN="$(cat ${osConfig.vaultix.secrets."githubToken-${user.userName}".path})"
            exec ${pkgs.gh}/bin/gh "$@"
          '';
        };
      };
    };
  };
}
