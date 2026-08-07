{
  den.aspects.devshells = {
    devShells = { pkgs, ... }: rec {
      default = nix;
      nix = pkgs.mkShell {
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
