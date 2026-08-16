{
  den.aspects.ssh = {
    nixos = {
      services.openssh = {
        enable = true;
        openFirewall = true;
        allowSFTP = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
      };
      # we have to preserve ssh host keys, otherwise each reboot regenerate it
      # maybe use values from config?
      preservation.preserveAt."/persist" = {
        files = [
          {
            file = "/etc/ssh/ssh_host_rsa_key";
            how = "symlink";
            configureParent = true;
            inInitrd = true;
          }
          {
            file = "/etc/ssh/ssh_host_rsa_key.pub";
            how = "symlink";
            configureParent = true;
            inInitrd = true;
          }
          {
            file = "/etc/ssh/ssh_host_ed25519_key";
            how = "symlink";
            configureParent = true;
            # this should fix vaultix order issue
            inInitrd = true;
          }
          {
            file = "/etc/ssh/ssh_host_ed25519_key.pub";
            how = "symlink";
            configureParent = true;
            inInitrd = true;
          }
        ];
        users.root.directories = [
          {
            directory = ".ssh";
            mode = "0700";
          }
        ];
      };
      vaultix.secrets = {
        keyRef = {
          file = ../user/id_ed25519_sk.age;
          mode = "0644";
        };
        keyRefA = {
          file = ../user/id_ed25519_sk_yka.age;
          mode = "0644";
        };
      };
    };

    provides.to-users = { user, ... }: {
      nixos = {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [
              {
                directory = ".ssh";
                mode = "0700";
              }
            ];
          };
        };
      };

      homeManager = { osConfig, ... }: {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings = {
            "*" = {
              identityFile = [
                osConfig.vaultix.secrets.keyRef.path
                osConfig.vaultix.secrets.keyRefA.path
              ];
            };
            router = {
              hostname = "192.168.8.1";
              user = "root";
              # my router need some old ssh config
              hostKeyAlgorithms = "ssh-rsa";
              fingerprintHash = "md5";
            };
            gh = {
              hostname = "github.com";
              user = "git";
            };
            gl = {
              hostname = "gitlab.com";
              user = "git";
            };
            gc = {
              hostname = "gitcode.com";
              user = "git";
            };
            cb = {
              hostname = "codeberg.org";
              user = "git";
            };
          };
        };
        programs.git.settings.url = {
          "git@github.com:".insteadOf = [
            "gh:"
            "github:"
          ];
          "git@gitlab.com:".insteadOf = [
            "gl:"
            "gitlab:"
          ];
          "git@gitcode.com:".insteadOf = [
            "gc:"
            "gitcode:"
          ];
          "git@codeberg.org:".insteadOf = [
            "cb:"
            "codeberg:"
          ];
        };
      };
    };
  };
}
