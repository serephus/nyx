{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    nixit.url = "github:serephus/nixit";
  };

  outputs =
    {
      nixpkgs,
      utils,
      nixit,
      ...
    }:
    {
      githubRepositories.typst = nixit.lib.githubRepository {
        owner = "serephus";
        name = "typst";

        description = "description";
        homepage = "homepage";
        topics = [
          "typst"
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
    // utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell =
          with pkgs;
          mkShell {
            name = "typst";
            buildInputs = [
              typst
              tinymist
            ];
          };
      }
    );
}
