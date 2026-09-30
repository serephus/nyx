{
  den.aspects.nvidia = {
    nixos = { pkgs, ... }: {
      nixpkgs.config = {
        allowUnfree = true;
        nvidia.acceptLicense = true;
      };

      environment.systemPackages = [ pkgs.cudaPackages.cudatoolkit ];
      hardware.nvidia-container-toolkit.enable = true;
    };
  };
}
