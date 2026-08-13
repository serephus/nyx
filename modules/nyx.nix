{ den, inputs, ... }: {
  # nyx host aspect
  den.aspects.nyx =
    let
      efiMountPoint = "/boot/efi";
      ephemeralRoot = true;
      spec = {
        efiMountPoint = efiMountPoint;
        secureboot = true;
        disks = [
          (den.aspects.rootFileSystem {
            device = "/dev/nvme0n1";
            ephemeralRoot = ephemeralRoot;
            encrypted = true;
            swapSize = 20;
            fido2 = true;
            efiMountPoint = efiMountPoint;
          })
          (den.aspects.preservation ephemeralRoot)
        ];
        # we're actually 8th gen, but I think it is okay?
        imports = [ inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen ];
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
