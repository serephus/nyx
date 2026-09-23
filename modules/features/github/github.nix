{
  den.aspects.github = {
    nixos = {
      vaultix.secrets.githubToken = {
        file = ./github-token.age;
        mode = "0644";
      };
    };
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
