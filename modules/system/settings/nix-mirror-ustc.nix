{
  flake.modules.nixos.nix-mirror-ustc = {
    nix.settings = {
      # mirrors
      substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
      ];
      trusted-substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
      ];
    };
  };
}
