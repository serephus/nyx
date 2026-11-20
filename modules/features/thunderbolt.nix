{
  den.aspects.thunderbolt = {
    nixos = {
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x15d4", ATTR{power/control}="on"
      '';
    };
  };
}
