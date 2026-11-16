{ den, inputs, ... }: {
  den.aspects.nixit = {
    # nixit authenticates with the same GitHub token as gh.
    includes = [ den.aspects.github-token ];

    nixos = { pkgs, ... }: {
      environment.systemPackages = [
        inputs.nixit.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };

    provides.to-users = {
      homeManager = { osConfig, pkgs, ... }: {
        home.packages = [
          (pkgs.writeShellScriptBin "nixit" ''
            export GITHUB_TOKEN="$(cat ${osConfig.vaultix.secrets.githubToken.path})"
            exec ${inputs.nixit.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/nixit "$@"
          '')
        ];
      };
    };
  };
}
