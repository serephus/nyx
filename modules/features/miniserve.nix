{ den, lib, ... }: {
  den.aspects.miniserve =
    let
      miniservePort = 11436;
    in
    {
      includes = [
        (den.aspects.cloudflared "file.sereph.us" "http://localhost:${lib.toString miniservePort}")
      ];
      nixos = { lib, pkgs, ... }: {
        systemd.services.miniserve = {
          enable = true;
          description = "Miniserve file serve.";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            ExecStart = "${lib.getExe pkgs.miniserve} -p ${lib.toString miniservePort} /data";
            Restart = "always";
            RestartSec = "5";
            DynamicUser = true;
          };
        };
        networking.firewall.allowedTCPPorts = [ miniservePort ];
      };
    };
}
