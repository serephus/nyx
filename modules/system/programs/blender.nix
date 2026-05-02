{ self, ... }:
{
  flake.modules.homeManager.blender =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.blender
      ];
    };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.blender
    ];
  };
}
