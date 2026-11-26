{ den, inputs, ... }: {
  # nyx host aspect
  den.aspects.nyx =
    let
      ephemeralRoot = true;
      spec = {
        secureboot = true;
        extraIncludes = [
          (den.aspects.rootFileSystem {
            device = "/dev/nvme0n1";
            ephemeralRoot = ephemeralRoot;
            encrypted = true;
            swapSize = 20;
            fido2 = true;
            includeHome = true;
          })
          (den.aspects.preservation ephemeralRoot)
          den.aspects.xmmrpc
          den.aspects.thunderbolt
          den.aspects.hotspot

          den.aspects.steam
          den.aspects.minecraft-client

          den.aspects.telegram
          den.aspects.obs
          den.aspects.blender
          den.aspects.freecad
          den.aspects.kicad

          den.aspects.github
          den.aspects.nixit
          den.aspects.termusic

          # ai related stuff
          den.aspects.pi-coding-agent
          (den.aspects.telagent ./features/telagent/telagent-bot-token-nyx.age)
          (den.aspects.opencode { })
        ];
        hardwareImports = [
          # we're actually 8th gen, but I think it is okay?
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
        ];
        hostPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK8KwCDs9Db33i+eDX8yaoafNqwfYDldQa2ZIkio7ph3";
        kernelModules = [
          "xhci_pci"
          "nvme"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
      };
    in
    den.aspects.laptop spec;
}
