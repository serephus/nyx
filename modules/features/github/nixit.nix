{ den, inputs, ... }: {
  den.aspects.nixit = {
    # nixit authenticates with the same GitHub token as gh.
    nixos = { pkgs, ... }: {
      environment.systemPackages = [
        inputs.nixit.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };

    provides.to-users = { user, ... }: {
      includes = [ (den.aspects.github-token user.userName) ];

      homeManager = { osConfig, pkgs, ... }: {
        home.packages = [
          (pkgs.writeShellScriptBin "nixit" ''
            export GITHUB_TOKEN="$(cat ${osConfig.vaultix.secrets."githubToken-${user.userName}".path})"
            exec ${inputs.nixit.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/nixit "$@"
          '')
        ];
      };
    };
  };
}
