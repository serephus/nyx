{ den, ... }: {

  den.default.includes = [ den.aspects.sudo ];

  # sudo-rs
  den.aspects.sudo = {
    nixos = {
      security.sudo.enable = false;
      security.sudo-rs.enable = true;
    };
  };
}
