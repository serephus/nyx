{ inputs, ... }: {
  flake-file.inputs = {
    xmmrpc = {
      url = "github:serephus/xmmrpc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  den.aspects.xmmrpc = {
    nixos = {
      imports = [ inputs.xmmrpc.nixosModules.default ];
      services.xmmrpc = {
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
