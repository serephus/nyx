{ den, ... }: {
  den.default.includes = [ den.aspects.sudo ];
  # sudo-rs
  # historically I have been using doas, and it's pretty good
  # but many programs just assumes/depends on sudo
  den.aspects.sudo = {
    nixos = {
      security.sudo.enable = false;
      security.sudo-rs.enable = true;
    };
  };
}
