{ den, ... }:
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
      preservation.preserveAt."/persist" = {
        files = [
          {
            file = "/etc/ssh/ssh_host_rsa_key";
            how = "symlink";
            configureParent = true;
          }
          {
            file = "/etc/ssh/ssh_host_ed25519_key";
            how = "symlink";
            configureParent = true;
          }
        ];
      };
    };

    provides.to-users = {
      homeManager = {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings = {
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
            # TODO: add gitcode/codeberg/etc
          };
        };
        programs.git.settings.url = {
          "git@github.com:".insteadOf = [
            "gh:"
            "github:"
            "https://github.com"
          ];
          "git@gitlab.com:".insteadOf = [
            "gl:"
            "gitlab:"
            "https://gitlab.com"
          ];
        };
      };
    };
  };
}
