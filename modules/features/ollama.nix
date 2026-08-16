{
  den.aspects.ollama = {
    nixos = { pkgs, ... }: {
      services.ollama = {
        enable = true;
        host = "0.0.0.0";
        # port = 8000; # custom port will require more configuration
        package = pkgs.ollama-cuda.override {
          # nvidia-smi --query-gpu=compute_cap --format=csv
          # the official pkgs.ollama-cuda package didn't build with computing
          # capacities 6.1, so we have to override it here
          cudaArches = [ "61" ];
        };
      };
      networking.firewall.allowedTCPPorts = [ 11434 ];
      preservation.preserveAt."/persist" = {
        directories = [ "/var/lib/private/ollama" ];
      };
    };
  };
}
