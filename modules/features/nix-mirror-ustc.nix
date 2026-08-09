{
  den.aspects.nix-mirror-ustc = {
    nixos =
      let
        url = "https://mirrors.ustc.edu.cn/nix-channels/store";
      in
      {
        nix.settings = {
          substituters = [ url ];
          trusted-substituters = [ url ];
        };
      };
  };
}
