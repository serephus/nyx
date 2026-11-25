{ den, inputs, ... }: {
  # x1c host aspect
  den.aspects.x1c =
    let
      ephemeralRoot = true;
      spec = {
        secureboot = true;
        extraIncludes = [
          (den.aspects.rootFileSystem {
            device = "/dev/sda";
            ephemeralRoot = ephemeralRoot;
            encrypted = true;
            swapSize = 10;
            fido2 = true;
            includeHome = true;
          })
          (den.aspects.preservation ephemeralRoot)
          (den.aspects.telagent ./features/telagent/telagent-bot-token-x1c.age)
          (den.aspects.opencode { baselineBun = true; })
        ];
        hardwareImports = [
          # we're 1st gen
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1
        ];
        hostPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILJqleV+Jw3ZlPxoz3tB4eDuwT3oBbq0lNcbokjgXvuT";
        kernelModules = [
          "xhci_pci"
          "ehci_pci"
          "ahci"
          "usb_storage"
          "sd_mod"
          "sdhci_pci"
        ];
      };
    in
    den.aspects.laptop spec;
}
