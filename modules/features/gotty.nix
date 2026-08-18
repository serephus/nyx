{ den, lib, ... }: {
  den.aspects.gotty =
    let
      gottyPort = 11435;
    in
    {
      includes = [
        (den.aspects.cloudflared "btm.sereph.us" "http://localhost:${lib.toString gottyPort}")
      ];
      nixos = { lib, pkgs, ... }: {
        systemd.services.gotty = {
          enable = true;
          description = "GoTTY Web Terminal";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            ExecStart = "${lib.getExe pkgs.gotty} -a 0.0.0.0 -p ${lib.toString gottyPort} ${lib.getExe pkgs.bottom}";
            Restart = "always";
            RestartSec = "5";
            DynamicUser = true;
          };
        };
        networking.firewall.allowedTCPPorts = [ gottyPort ];
      };
    };
}
