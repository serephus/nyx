{ inputs, ... }: {
  flake-file.inputs = {
    xmm7360 = {
      url = "github:serephus/xmm7360.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  den.aspects.xmm7360 = {
    nixos = {
      imports = [ inputs.xmm7360.nixosModules.default ];
      xmm7360 = {
        enable = true;
        autoStart = true;
        config = {
          apn = "bjlenovo12.njm2mapn";
          noresolv = true;
        };
      };
      networking.nameservers = [
        "8.8.8.8"
        "8.8.4.4"
        "1.1.1.1"
      ];
    };
  };
}
