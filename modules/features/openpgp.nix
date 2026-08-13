{
  den.aspects.openpgp = fingerprint: {
    nixos = { pkgs, ... }: {
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryPackage = pkgs.pinentry-curses;
      };
      hardware.gpgSmartcards.enable = true;
      environment.systemPackages = [ pkgs.pinentry-curses ];
      users.groups.pcscd = { };
      users.groups.plugdev = { };
      # looks like we need this if we don't log into desktop environment
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if ((action.id == "org.debian.pcsc-lite.access_pcsc" ||
               action.id == "org.debian.pcsc-lite.access_card") &&
               subject.isInGroup("wheel")) {
            return polkit.Result.YES;
          }
        });
      '';
    };
    provides.to-users = { user, ... }: {
      nixos = {
        users.users."${user.userName}" = {
          extraGroups = [
            "pcscd"
            "plugdev"
          ];
        };
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [
              {
                directory = ".gnupg";
                mode = "0700";
              }
            ];
          };
        };
      };
      homeManager = {
        programs.fish.shellAbbrs = {
          gts = "git tag -S${fingerprint}";
          gms = "git commit -S${fingerprint}";
        };

        programs.gpg = {
          enable = true;
          scdaemonSettings = {
            disable-ccid = true;
            pcsc-shared = true;
          };
        };
      };
    };
  };
}
