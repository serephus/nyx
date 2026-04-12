{ self, ... }:
{
  # predefine nvme0n1 disk, we should be able to reuse it in desktop host
  flake.modules = (self.factory.disko "nvme0n1");
}
