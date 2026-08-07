{ den, inputs, ... }: {
  den.schema.flake-system.includes = [ den.aspects.devshells ];
}
