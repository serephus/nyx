{ den, lib, ... }: {
  den.aspects.ollama =
    let
      webuiPort = 11439;
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
          environmentVariables = {
            OLLAMA_CONTEXT_LENGTH = "65536";
            OLLAMA_FLASH_ATTENTION = "1";
            OLLAMA_KV_CACHE_TYPE = "q4_0";
          };
        };
        # open-webui is not worth it, I have to compile a complete Python ecosystem
        services.open-webui = {
          enable = true;
          host = "0.0.0.0";
          port = webuiPort;
          openFirewall = true;
          environment = {
            OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString ollamaPort}";
            # Disable authentication\n
            WEBUI_AUTH = "TRUE";
          };
          # ollamaUrl = "http://127.0.0.1:${lib.toString ollamaPort}";
        };
        networking.firewall.allowedTCPPorts = [
          ollamaPort
          webuiPort
        ];
        preservation.preserveAt."/persist" = {
          directories = [
            "/var/lib/private/ollama"
            "/var/lib/private/open-webui"
          ];
        };
      };
    };
}
