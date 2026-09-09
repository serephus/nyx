{
  den.aspects.devshells = {
    devShells = { pkgs, ... }: rec {
      default = nix;
      nix = pkgs.mkShell {
        name = "nyx";
        buildInputs = [
          pkgs.nil
          pkgs.nixd
          pkgs.nixfmt
          pkgs.nh
        ];
      };
    };
  };
}
