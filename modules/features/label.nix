{ den, self, ... }: {
  den.default.includes = [ den.aspects.label ];
  # this create a identity label for nixos generations in bootloader
  den.aspects.label = {
    nixos = {
      system.configurationRevision = self.rev or null;
      system.nixos.label =
        if self.sourceInfo ? lastModifiedDate && self.sourceInfo ? shortRev then
          "${builtins.substring 0 8 self.sourceInfo.lastModifiedDate}.${self.sourceInfo.shortRev}"
        else
          "0-dirty";
    };
  };
}
