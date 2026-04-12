{
  # flake.perSystem dev shells
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt;
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.nil
          pkgs.nixd
          pkgs.nixfmt
        ];
      };
    };
}
