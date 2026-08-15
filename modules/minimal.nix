{ den, inputs, ... }: {
  # minimal installation live iso
  den.aspects.minimal = {
    includes = [
      # for the preservation nixosModule import
      (den.aspects.preservation false)

      den.aspects.doc

      den.aspects.git
      den.aspects.fish
      den.aspects.helix
      den.aspects.tmux

      # minimal does not have vaultix hence can't have wifi config builtin
    ];

    # host NixOS configuration
    nixos = { lib, modulesPath, ... }: {
      imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];

      time.timeZone = "Asia/Shanghai";
      boot.zfs.forceImportRoot = lib.mkForce false;
      users.users.root = {
        # we may want to set root password here
        # hashedPassword = "";
        openssh.authorizedKeys.keyFiles = [ ./user/id_ed25519_sk.pub ];
      };
    };
  };

  den.schema.flake-system.includes = [ den.aspects.buildiso ];

  den.aspects.buildiso = {
    packages = { ... }: {
      iso = inputs.self.nixosConfigurations.minimal.config.system.build.isoImage;
    };
  };
}
