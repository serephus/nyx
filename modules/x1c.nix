{ den, inputs, ... }: {
  # x1c host aspect
  den.aspects.x1c =
    let
      efiMountPoint = "/boot/efi";
      ephemeralRoot = true;
      spec = {
        efiMountPoint = efiMountPoint;
        secureboot = true;
        disks = [
          (den.aspects.rootFileSystem {
            device = "/dev/sda";
            ephemeralRoot = ephemeralRoot;
            encrypted = true;
            swapSize = 10;
            fido2 = true;
            efiMountPoint = efiMountPoint;
          })
          (den.aspects.preservation ephemeralRoot)
        ];
        imports = [
          inputs.nixos-hardware.nixosModules.common-cpu-intel
          inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
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
