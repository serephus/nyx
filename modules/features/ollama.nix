{ den, lib, ... }: {
  den.aspects.ollama =
    let
      webuiPort = 8080;
      ollamaPort = 11434;
    in
    {
      includes = [
        (den.aspects.cloudflared "api.sereph.us" "http://localhost:${lib.toString ollamaPort}")
        (den.aspects.cloudflared "chat.sereph.us" "http://localhost:${lib.toString webuiPort}")
      ];
      nixos = { pkgs, ... }: {
        services.ollama = {
          enable = true;
          host = "0.0.0.0";
          port = ollamaPort;
          package = pkgs.ollama-cuda.override {
            # nvidia-smi --query-gpu=compute_cap --format=csv
            # the official pkgs.ollama-cuda package didn't build with computing
            # capacities 6.1, so we have to override it here
            cudaArches = [ "61" ];
          };
        };
        services.open-webui = {
          enable = true;
          openFirewall = true;
          port = webuiPort;
          host = "0.0.0.0";
          environment = {
            OLLAMA_API_BASE_URL = "http://127.0.0.1:${lib.toString ollamaPort}";
            # Disable authentication
            WEBUI_AUTH = "False";
          };
        };
        networking.firewall.allowedTCPPorts = [
          ollamaPort
          webuiPort
        ];
        preservation.preserveAt."/persist" = {
          directories = [ "/var/lib/private/ollama" ];
        };
      };
    };
}
