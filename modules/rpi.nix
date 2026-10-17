# Raspberry Pi 4B (8G) host.
#
# Bootstrap note: a fresh Pi has no re-encrypted vaultix cache yet. While
# `bootstrap = true`, the vaultix activation services are disabled and the
# root/serephus accounts get an empty initial password (SSH still only accepts
# the authorized keys from modules/user/serephus.nix). After the first boot:
#
#   1. read the real host key: ssh-keyscan rpi (or
#      cat /etc/ssh/ssh_host_ed25519_key.pub on the Pi)
#   2. put it into `hostPubKey` below and set `bootstrap = false`
#   3. add `rpi` to `flake.vaultix.nodes` in modules/vaultix.nix
#   4. run `nix run .#seal`, then rebuild the Pi
{
  den,
  inputs,
  ...
}:
let
  # set to false once the real host key is in place and secrets are sealed
  bootstrap = true;

  # throwaway key, only used while bootstrapping
  hostPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAZB9ax2NN6PEMqgYweeqAaCbwLu/ICaPsa4a5bKmlar";

  efiMountPoint = "/boot";
  firmwareMountPoint = "/boot/firmware";
  ephemeralRoot = true;
in
{
  # rpi host aspect
  den.aspects.rpi = {
    includes = [
      # SD card layout: FIRMWARE + ESP + btrfs root, matching the other hosts
      (den.aspects.rootFileSystem {
        device = "/dev/mmcblk0";
        scheme = "rpi";
        ephemeralRoot = ephemeralRoot;
        encrypted = false;
        fido2 = false;
        swapSize = 8;
        efiMountPoint = efiMountPoint;
        firmwareMountPoint = firmwareMountPoint;
        includeHome = true;
      })
      (den.aspects.preservation ephemeralRoot)
      (den.aspects.vaultix hostPubKey)
      den.aspects.root
      den.aspects.kernel-parameter

      # extra nix configs
      den.aspects.nix-mirror-ustc
      den.aspects.clean-flake-registry

      # essential services and programs
      den.aspects.ssh

      # core cli programs
      den.aspects.git
      den.aspects.fish
      den.aspects.helix
      den.aspects.tmux
      den.aspects.common-cli-tools
      den.aspects.direnv
    ];

    # host NixOS configuration
    nixos = { config, lib, ... }: {
      imports = [
        inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base
      ];

      # timezone
      time.timeZone = "Asia/Shanghai";

      boot = {
        zswap.enable = config.swapDevices != [ ];
        initrd = {
          systemd.enable = true;
          # SD card root
          availableKernelModules = [
            "sdhci"
            "sdhci_iproc"
            "mmc_block"
          ];
          kernelModules = [ ];
        };
        kernelModules = [ ];
        extraModulePackages = [ ];
      };

      # Bootstrap: don't wait for vaultix secrets that don't exist yet. The
      # authorized SSH keys are plain files, so key login still works.
      users.users.root.hashedPasswordFile = lib.mkIf bootstrap (lib.mkForce null);
      users.users.root.initialHashedPassword = lib.mkIf bootstrap "";
      users.users.serephus.hashedPasswordFile = lib.mkIf bootstrap (lib.mkForce null);
      users.users.serephus.initialHashedPassword = lib.mkIf bootstrap "";
      systemd.services.vaultix-activate.enable = lib.mkIf bootstrap (lib.mkForce false);
      systemd.services.vaultix-activate-before-user.enable = lib.mkIf bootstrap (lib.mkForce false);
    };
  };
}
