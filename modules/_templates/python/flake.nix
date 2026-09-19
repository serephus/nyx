{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixit.url = "github:serephus/nixit";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      nixit,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python3; # this is for uv
        # this is for local nix
        python' = python.withPackages (p: [
          # add package dependencies here
        ]);
      in
      {
        devShell = pkgs.mkShell {
          name = "python";
          buildInputs = [
            # do we need both python available to mix uv & nix
            python
            python'
            pkgs.basedpyright
            pkgs.black
            pkgs.ruff
            pkgs.uv
          ];

          # Force uv to use the Python interpreter provided by Nix
          UV_PYTHON_DOWNLOADS = "never";
          UV_PYTHON = nixpkgs.lib.getExe python;
        };

        githubRepositories.python = nixit.lib.githubRepository {
          owner = "serephus";
          name = "python";

          description = "description";
          homepage = "homepage";
          topics = [
            "python"
          ];
          visibility = "public";

          features = {
            wiki.enable = false;
            issues.enable = true;
            projects.enable = false;
            discussions.enable = false;
          };

          is_template = false;
          is_archived = false;

          pull = {
            merge.enable = true;
            squash.enable = false;
            rebase.enable = false;
            auto_merge = true;
            delete_branch_on_merge = true;
            update_branch = true;
          };

          actions = {
            enable = true;
            policy = "all";
            default_token_permissions = "read";
            allow_pr_approval = false;
          };

          rulesets = {
            default = {
              enforcement = "active";
              conditions.ref_name.include = [ "~DEFAULT_BRANCH" ];
              rules = [
                { type = "deletion"; }
                { type = "non_fast_forward"; }
              ];
            };
          };
        };
      }
    );
}
