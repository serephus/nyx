{ inputs, ... }: {
  flake-file.inputs = {
    nixit = {
      url = "github:serephus/nixit";
      inputs = {
        flake-utils.follows = "flake-utils";
        naersk.follows = "naersk";
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };
  };

  flake.githubRepositories.nyx = inputs.nixit.lib.githubRepository {
    owner = "serephus";
    name = "nyx";

    description = "My NixOS configs written from scratch with den.";
    homepage = "https://github.com/serephus/nyx";
    topics = [
      "nix"
      "nix-flake"
      "nixos"
      "nixos-config"
      "nixos-configuration"
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
      main = {
        enforcement = "active";
        conditions.ref_name.include = [ "~DEFAULT_BRANCH" ];
        rules = [
          { type = "deletion"; }
          { type = "non_fast_forward"; }
        ];
      };
      pr = {
        enforcement = "active";
        conditions.ref_name.include = [ "~DEFAULT_BRANCH" ];
        rules = [
          {
            type = "required_status_checks";
            parameters = {
              strict_required_status_checks_policy = true;
              required_status_checks = [
                { "context" = "linear-check"; }
                { "context" = "Nix flake check ubuntu-latest"; }
              ];
            };
          }
        ];
      };
    };
  };
}
