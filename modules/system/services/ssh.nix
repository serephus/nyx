{ self, ... }:
{
  # enable system level ssh service
  flake.modules.nixos.ssh = {
    services.openssh = {
      enable = true;
      openFirewall = true;
      allowSFTP = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  flake.modules.nixos.minimal = {
    imports = [ self.modules.nixos.ssh ];
  };

  # this is for user level ssh config
  flake.modules.homeManager.ssh = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        router = {
          hostname = "192.168.8.1";
          user = "root";
          extraOptions = {
            hostKeyAlgorithms = "ssh-rsa";
            fingerprintHash = "md5";
          };
        };
        gh = {
          hostname = "github.com";
          user = "git";
        };
        gl = {
          hostname = "gitlab.com";
          user = "git";
        };
      };
    };
  };

  flake.modules.homeManager.minimal = {
    imports = [ self.modules.homeManager.ssh ];
  };
}
