{
  den.aspects.kernel-parameter = {
    nixos = {
      boot = {
        kernelParams = [
          # don't display on screen any kernel logs during boot
          "quiet"
          # don't apply security patches
          "mitigations=off"
        ];
        kernel.sysctl = {
          "vm.swappiness" = 30;
          "vm.vfs_cache_pressure" = 50;
          "kernel.sysrq" = 1;
        };
      };
    };
  };
}
