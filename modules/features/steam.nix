{ den, ... }: {
  den.aspects.steam = {
    includes = [
      (den.batteries.unfree [
        "steam"
        "steam-unwrapped"
      ])
    ];
    nixos = { pkgs, ... }: {
      programs.steam = {
        enable = true;
        package =
          let
            proxyServer = "http://localhost:7890";
          in
          pkgs.steam.overrideAttrs (oldAttrs: {
            # Use nativeBuildInputs to ensure wrapProgram is available
            nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];

            # Post-installation phase to wrap the binary
            postInstall = (oldAttrs.postInstall or "") + ''
              # Wrap the main executable (usually in $out/bin)
              wrapProgram $out/bin/steam \
                --set http_proxy "${proxyServer}" \
                --set https_proxy "${proxyServer}" \
                --set HTTP_PROXY "${proxyServer}" \
                --set HTTPS_PROXY "${proxyServer}"
            '';
          });
      };
    };
    provides.to-users = { user, ... }: {
      nixos = {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [
              ".steam"
              ".local/share/Steam"
              ".local/share/steam"
            ];
          };
        };
      };
    };
  };
}
