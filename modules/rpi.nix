# Raspberry Pi 4B (8G) host.
{
  den,
  inputs,
  ...
}:
let
  # TODO: replace with the Pi's real SSH host public key
  hostPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAZB9ax2NN6PEMqgYweeqAaCbwLu/ICaPsa4a5bKmlar";

  ephemeralRoot = true;
in
{
  # rpi host aspect
  den.aspects.rpi = {
    includes = [
      # SD card layout: FIRMWARE + ESP + btrfs root, matching the other hosts
      (den.aspects.rootFileSystem {
        device = "/dev/mmcblk0";
        bootPartitions = [
          {
            # config.txt, DTBs and U-Boot; the Required Partition attribute
            # tells udisks to leave it alone.
            name = "FIRMWARE";
            size = "1024M";
            type = "0700"; # Microsoft basic data
            attributes = [ 0 ];
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot/firmware";
              mountOptions = [
                "noatime"
                "noauto"
                "x-systemd.automount"
                "x-systemd.idle-timeout=1min"
              ];
            };
          }
          {
            # extlinux/kernel/initrd; U-Boot finds extlinux.conf via the
            # Legacy BIOS Bootable GPT attribute.
            name = "ESP";
            size = "1024M";
            type = "EF00";
            attributes = [ 2 ];
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "noatime"
                "noauto"
                "x-systemd.automount"
                "x-systemd.idle-timeout=1min"
                "umask=0077"
              ];
            };
          }
        ];
        ephemeralRoot = ephemeralRoot;
        encrypted = false;
        fido2 = false;
        swapSize = 8;
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
    nixos = { config, ... }: {
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
    };
  };
}
