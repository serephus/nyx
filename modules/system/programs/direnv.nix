{ self, ... }:
{
  flake.modules.homeManager.direnv = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global.strict_env = true;
        whitelist.prefix = [
          "~/dev/nyx"
          "~/dev/blog"
          "~/dev/rust"
          "~/dev/python"
          "~/dev/cpp"
          "~/dev/resume"
          "~/dev/misc"
        ];
      };
    };
  };

  flake.modules.homeManager.basic = {
    imports = [
      self.modules.homeManager.direnv
    ];
  };
}
