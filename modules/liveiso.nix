{ den, inputs, ... }: {
  # minimal installation live iso
  den.aspects.liveiso = {
    includes = [
      den.batteries.hostname
      (den.aspects.preservation false)

      den.aspects.doc

      den.aspects.git
      den.aspects.fish
      den.aspects.helix
      den.aspects.tmux

      den.aspects.wifi
    ];

    # host NixOS configuration
    nixos = { lib, modulesPath, ... }: {
      imports = [
        (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
      ];

      time.timeZone = "Asia/Shanghai";
      boot.zfs.forceImportRoot = lib.mkForce false;
      networking.networkmanager.enable = lib.mkForce false;

      # enable ssh service for liveiso
      services.openssh = {
        enable = true;
        openFirewall = true;
        allowSFTP = true;
      };
    };
  };

  den.schema.flake-system.includes = [ den.aspects.buildiso ];

  den.aspects.buildiso = {
    packages =
      { ... }:
      let
        host = inputs.self.nixosConfigurations.liveiso.config;
      in
      {
        iso = host.system.build.isoImage;
      };
  };
}
