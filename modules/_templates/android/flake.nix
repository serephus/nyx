{
  description = "Android template with Kotlin, Jetpack Compose and Gradle";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixit = {
      url = "github:serephus/nixit";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      nixit,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      githubRepositories.android = nixit.lib.githubRepository {
        owner = "serephus";
        name = "android";

        description = "Android app template: Kotlin, Jetpack Compose and Gradle";
        homepage = "homepage";
        topics = [
          "android"
          "kotlin"
          "jetpack-compose"
          "gradle"
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
          pr = {
            enforcement = "active";
            conditions.ref_name.include = [ "~DEFAULT_BRANCH" ];
            rules = [
              {
                type = "required_status_checks";
                parameters = {
                  strict_required_status_checks_policy = true;
                  required_status_checks = [
                    { "context" = "build"; }
                  ];
                };
              }
            ];
          };
        };
      };
    }
    // flake-utils.lib.eachSystem systems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        lib = pkgs.lib;

        jdk = pkgs.jdk21;
        gradle = pkgs.gradle_8;

        # Keep these in sync with gradle/libs.versions.toml and
        # gradle/wrapper/gradle-wrapper.properties.
        androidComposition =
          extra:
          pkgs.androidenv.composeAndroidPackages (
            {
              platformVersions = [ "36" ];
              buildToolsVersions = [ "36.0.0" ];
              includeCmake = false;
              includeNDK = false;
              includeSources = false;
            }
            // extra
          );

        sdk = androidComposition { };
        emulatorSdk = androidComposition {
          includeEmulator = true;
          includeSystemImages = true;
          systemImageTypes = [ "google_apis_playstore" ];
          abiVersions = [ "x86_64" ];
        };

        androidHome = composition: "${composition.androidsdk}/libexec/android-sdk";

        mkAndroidShell =
          {
            name,
            composition,
            extraPackages ? [ ],
          }:
          pkgs.mkShell {
            inherit name;

            packages = [
              jdk
              gradle
              composition.androidsdk
            ]
            ++ extraPackages;

            JAVA_HOME = jdk.home;
            ANDROID_HOME = androidHome composition;
            ANDROID_SDK_ROOT = androidHome composition;
            # NixOS cannot run the generic-Linux aapt2 that AGP downloads from
            # Maven, so point AGP at the SDK's patched copy instead.
            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidHome composition}/build-tools/36.0.0/aapt2";

            shellHook = ''
              export ANDROID_AVD_HOME="$PWD/.android/avd"
              export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
            '';
          };

        # Gradle drives the actual Android build. Nixpkgs no longer ships
        # buildGradleAndroidApplication, and a sandboxed Gradle build would need
        # every Maven artifact vendored, so these apps run nixpkgs' Gradle.
        # There is no wrapper: everything uses ${gradle}/bin/gradle, so no Gradle
        # distribution is fetched from services.gradle.org at runtime.
        mkGradleApp = name: task: {
          type = "app";
          program = "${
            pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = [
                jdk
                gradle
              ];
              text = ''
                # Walk up until we find the project (the directory with a Gradle
                # build).
                dir="$PWD"
                while [ "$dir" != "/" ] && [ ! -f "$dir/settings.gradle.kts" ] && [ ! -f "$dir/settings.gradle" ]; do
                  dir="$(dirname "$dir")"
                done
                if [ "$dir" = "/" ]; then
                  echo "error: no Gradle project found above $PWD" >&2
                  exit 1
                fi
                cd "$dir"

                export JAVA_HOME="${jdk.home}"
                export ANDROID_HOME="${androidHome sdk}"
                export ANDROID_SDK_ROOT="$ANDROID_HOME"
                export GRADLE_OPTS="-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidHome sdk}/build-tools/36.0.0/aapt2"
                export PATH="$ANDROID_HOME/platform-tools:$PATH"

                exec ${gradle}/bin/gradle --no-daemon ${task} "$@"
              '';
            }
          }/bin/${name}";
          meta.description = "Run Gradle ${task}";
        };

        apps' = {
          apk = mkGradleApp "apk" "assembleDebug";
          release = mkGradleApp "release" "assembleRelease";
          install = mkGradleApp "install" "installDebug";
          lint = mkGradleApp "lint" "lintDebug";
          test = mkGradleApp "test" "testDebugUnitTest";
          clean = mkGradleApp "clean" "clean";
        };
      in
      {
        apps = apps' // {
          default = apps'.apk;
        };

        devShells = {
          default = mkAndroidShell {
            name = "android";
            composition = sdk;
          };
        }
        // lib.optionalAttrs pkgs.stdenv.hostPlatform.isx86_64 {
          emulator = mkAndroidShell {
            name = "android-emulator";
            composition = emulatorSdk;
          };
        };
      }
    );
}
