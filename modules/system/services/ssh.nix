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
    programs = {
      ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          router = {
            hostname = "192.168.8.1";
            user = "root";
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
        };
      };
      git.settings.url = {
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

  flake.modules.homeManager.minimal = {
    imports = [ self.modules.homeManager.ssh ];
  };
}
