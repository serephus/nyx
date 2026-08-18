{ den, ... }: {
  den.schema.flake-system.includes = [ den.aspects.devshells ];
  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixfmt;
  };
}
