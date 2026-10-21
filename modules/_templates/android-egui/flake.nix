{
  description = "Android template with Rust, egui and cargo-apk";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixit = {
      url = "github:serephus/nixit";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "rust-overlay";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      rust-overlay,
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
      githubRepositories.android-egui = nixit.lib.githubRepository {
        owner = "serephus";
        name = "android-egui";

        description = "Android app template: Rust, egui and cargo-apk";
        homepage = "homepage";
        topics = [
          "android"
          "rust"
          "egui"
          "nix"
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
          overlays = [ rust-overlay.overlays.default ];
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        inherit (pkgs) lib;

        # The app is a `cdylib` that Android loads as a shared library, so the
        # rust toolchain needs the target triples installed.
        rust = pkgs.rust-bin.stable.latest.default.override {
          targets = [
            "aarch64-linux-android" # phones (64 bit)
            "armv7-linux-androideabi" # old 32 bit phones
            "x86_64-linux-android" # emulator
          ];
          extensions = [
            "clippy"
            "rust-analyzer"
            "rustfmt"
          ];
        };

        # Keep these in sync with [package.metadata.android] in Cargo.toml.
        #
        # `cargo apk` (through ndk-build) only accepts platforms within the
        # NDK's NDK_MAX_PLATFORM_LEVEL, which is 35 for NDK r28 and r29, so the
        # SDK platform stays at 35. Build tools are independent of that.
        androidSdkVersion = "35";
        buildToolsVersion = "36.0.0";
        ndkVersion = "28.2.13676358";

        jdk = pkgs.jdk21;

        androidComposition =
          extra:
          pkgs.androidenv.composeAndroidPackages (
            {
              platformVersions = [ androidSdkVersion ];
              buildToolsVersions = [ buildToolsVersion ];
              includeNDK = true;
              inherit ndkVersion;
              includeCmake = false;
              includeSources = false;
              includeEmulator = false;
              includeSystemImages = false;
            }
            // extra
          );

        sdk = androidComposition { };

        androidHome = composition: "${composition.androidsdk}/libexec/android-sdk";
        ndkHome = composition: "${androidHome composition}/ndk/${ndkVersion}";
        buildTools = composition: "${androidHome composition}/build-tools/${buildToolsVersion}";

        # A release APK, built hermetically (crates come from Cargo.lock).
        #
        # `cargo apk` refuses to produce an unsigned release build, so it is
        # signed with a throwaway key generated during the build. `nix run .#sign`
        # and `nix run .#install` re-sign it with your own key.
        apkFor =
          {
            target ? "aarch64-linux-android",
          }:
          pkgs.rustPlatform.buildRustPackage {
            pname = "template-apk";
            version = (fromTOML (builtins.readFile ./Cargo.toml)).package.version;

            src = ./.;

            cargoLock.lockFile = ./Cargo.lock;
            doCheck = false; # the tests run on the host, see the README

            nativeBuildInputs = [
              (pkgs.rust-bin.stable.latest.default.override { targets = [ target ]; })
              pkgs.cargo-apk
              sdk.androidsdk
              jdk # keytool, apksigner
            ];

            ANDROID_HOME = androidHome sdk;
            ANDROID_SDK_ROOT = androidHome sdk;
            ANDROID_NDK_ROOT = ndkHome sdk;
            ANDROID_NDK_HOME = ndkHome sdk;

            buildPhase = ''
              runHook preBuild

              export HOME=$TMPDIR
              keytool -genkeypair -noprompt \
                -keystore "$TMPDIR/build.keystore" \
                -storepass throwaway -keypass throwaway \
                -alias template -keyalg RSA -keysize 2048 -validity 10000 \
                -dname "CN=Template build key, O=Template, C=US" >/dev/null
              export CARGO_APK_RELEASE_KEYSTORE="$TMPDIR/build.keystore"
              export CARGO_APK_RELEASE_KEYSTORE_PASSWORD=throwaway

              cargo apk build --lib --release --target ${target}

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out
              cp target/release/apk/template.apk $out/template.apk
              runHook postInstall
            '';

            meta = {
              description = "Android template APK for ${target}";
              platforms = lib.platforms.linux;
            };
          };

        # Sign an APK with your own key: a local keystore, or a PKCS#11 token
        # such as a YubiKey (the PIN is prompted for).
        #
        # Careful when editing the script below: it is a Nix indented string, so
        # bash's `${...}` has to be written `''${...}`, otherwise Nix
        # interpolates it at evaluation time.
        signScript = pkgs.writeShellScriptBin "template-sign" ''
          set -euo pipefail

          export PATH=${
            lib.makeBinPath [
              sdk.androidsdk
              pkgs.jdk17
              pkgs.opensc
            ]
          }:${sdk.androidsdk}/libexec/android-sdk/build-tools/${buildToolsVersion}:$PATH

          opensc_pkcs11=${pkgs.opensc}/lib/opensc-pkcs11.so
          ykcs11=${pkgs.yubico-piv-tool}/lib/libykcs11.so

          usage() {
            cat <<'EOF'
          usage: template-sign [options] [APK]      (default: ./template.apk)

          Signs (or re-signs) an APK in place.

          Keystore (default)
            APP_KEYSTORE           default: ~/.android/template-release.keystore
            APP_KEYSTORE_PASSWORD  default: template
          (the keystore is created on first use)

          PKCS#11 token (YubiKey, Nitrokey, HSM): keep the key on the device
            --pkcs11              sign with a token
            --list                show the token, its keys and certificates
            --alias NAME          key to use (default: auto-detected)
            --slot N              slotListIndex, default 0
            --lib PATH            PKCS#11 module: Yubico's libykcs11 by default,
                                  OpenSC as a fallback
          The PIN is asked for interactively (or read from stdin when piped).
          APP_PKCS11_PIN can still be set for scripts, APP_PKCS11_LIB/SLOT/ALIAS
          work as defaults for the options above.
          EOF
          }

          token_hints() {
            cat >&2 <<'EOF'

          Things that usually go wrong:
            * no token: is the YubiKey plugged in? On NixOS enable pcscd
              (services.pcscd.enable = true) and check with `pcsc_scan`.
            * wrong PIN: three failures block the PIN. Unblock with the PUK:
              `ykman piv access unblock-pin`, then `ykman piv access change-pin`.
            * no certificate on the token: create one in the signing slot 9c:
              ykman piv keys generate --pin-policy once --algorithm RSA2048 \\
                9c pubkey.pem
              ykman piv certificates generate --subject "CN=... upload" 9c pubkey.pem
            * a P-384/P-521 key cannot sign APKs; Android accepts RSA
              2048/3072/4096 and EC P-256.
            * touch policy "always": touch the key once per signature scheme.
            * PIN policy "always" (CKA_ALWAYS_AUTHENTICATE): Java's PKCS#11
              provider cannot re-enter the PIN for every signature, so it fails
              with CKR_USER_NOT_LOGGED_IN. Check with `ykman piv keys info 9c`
              and regenerate the signing key with --pin-policy once.
            `template-sign --list` shows what the token actually holds.
          EOF
          }

          # Show the token, its certificates and their key algorithms.
          list_token() {
            local module=$1 info
            if ! info=$(pkcs11-tool --module "$module" --list-slots 2>&1); then
              echo "$info" >&2
              token_hints
              return 1
            fi
            echo "$info"
            echo
            echo "Certificates:"
            pkcs11-tool --module "$module" --list-objects --type cert 2>/dev/null |
              sed -n 's/^  label: */  - /p'
            echo "Keys:"
            pkcs11-tool --module "$module" --list-objects --type pubkey 2>/dev/null |
              grep -E "^Public Key Object|^  label:" | sed 's/^/  /'
          }

          # Choose the certificate to sign with: --alias wins, then the PIV
          # digital-signature slot, then a sole certificate, then ask.
          pick_alias() {
            local module=$1 cert choice
            if [[ -n $alias ]]; then
              printf '%s' "$alias"
              return 0
            fi
            mapfile -t certs < <(
              pkcs11-tool --module "$module" --list-objects --type cert 2>/dev/null |
                sed -n 's/^  label: *//p'
            )
            ((''${#certs[@]})) || return 1
            for cert in "''${certs[@]}"; do
              case "$cert" in
                *"Digital Signature"*)
                  printf '%s' "$cert"
                  return 0
                  ;;
              esac
            done
            if ((''${#certs[@]} == 1)); then
              printf '%s' "''${certs[0]}"
              return 0
            fi
            echo "several keys on the token:" >&2
            local i
            for i in "''${!certs[@]}"; do
              echo "  $((i + 1))) ''${certs[i]}" >&2
            done
            read -r -p "Which one? " choice
            printf '%s' "''${certs[choice - 1]:?invalid choice}"
          }

          # Read the PIN without echoing it, printing one '*' per keystroke.
          read_pin() {
            local pin="" char=""
            if [[ -n ''${APP_PKCS11_PIN:-} ]]; then
              printf '%s' "$APP_PKCS11_PIN"
              return 0
            fi
            if [[ ! -t 0 ]]; then
              # Piped, e.g. `pass show yubikey | template-sign --pkcs11 app.apk`
              IFS= read -r pin || true
              printf '%s' "$pin"
              return 0
            fi
            printf 'YubiKey PIN: ' >&2
            while IFS= read -r -s -n1 char; do
              case "$char" in
                "")
                  break # Enter
                  ;;
                $'\x7f' | $'\b') # Backspace
                  if [[ -n $pin ]]; then
                    pin=''${pin%?}
                    printf '\b \b' >&2
                  fi
                  ;;
                *)
                  pin+=$char
                  printf '*' >&2
                  ;;
              esac
            done
            printf '\n' >&2
            printf '%s' "$pin"
          }

          apk=""
          alias=""
          slot=''${APP_PKCS11_SLOT:-0}
          module=''${APP_PKCS11_LIB:-}
          use_token=0
          list_only=0

          while (($#)); do
            case "$1" in
              --pkcs11) use_token=1 ;;
              --list) list_only=1; use_token=1 ;;
              --alias) use_token=1; alias=''${2:?--alias needs a value}; shift ;;
              --slot) use_token=1; slot=''${2:?--slot needs a value}; shift ;;
              --lib) use_token=1; module=''${2:?--lib needs a value}; shift ;;
              -h | --help) usage; exit 0 ;;
              -*) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
              *) apk=$1 ;;
            esac
            shift
          done

          # Older behaviour: the environment selects the token as well.
          if [[ -n ''${APP_PKCS11_LIB:-} || -n ''${APP_PKCS11_PIN:-} ]]; then
            use_token=1
          fi
          [[ -n ''${APP_PKCS11_ALIAS:-} ]] && alias=$APP_PKCS11_ALIAS
          requested_alias=$alias

          if ((list_only)); then
            # Show the first module that actually sees a token.
            for candidate in "''${module:-$ykcs11}" "$ykcs11" "$opensc_pkcs11"; do
              [[ -f $candidate ]] || continue
              if pkcs11-tool --module "$candidate" --list-slots 2>/dev/null |
                grep -q "token label"; then
                list_token "$candidate"
                exit $?
              fi
            done
            echo "no PKCS#11 token found (is the YubiKey plugged in?)" >&2
            token_hints
            exit 1
          fi

          apk=''${apk:-./template.apk}
          [[ -f $apk ]] || { echo "no such APK: $apk" >&2; exit 1; }

          if ((use_token)); then
            # Yubico's own module is the one that keeps the PIV login alive
            # between the KeyStore lookup and the signature; OpenSC is used as a
            # fallback (and is what other tokens need). --lib picks only one.
            if [[ -n $module ]]; then
              modules=("$module")
            else
              modules=("$ykcs11" "$opensc_pkcs11")
            fi

            pin=""
            signed=0
            for module in "''${modules[@]}"; do
              [[ -f $module ]] || {
                echo "PKCS#11 module not found: $module" >&2
                continue
              }
              if ! info=$(pkcs11-tool --module "$module" --list-slots 2>&1) ||
                ! grep -q "token label" <<<"$info"; then
                echo "no token via ''${module##*/}" >&2
                continue
              fi

              label=$(sed -n 's/.*token label *: *//p' <<<"$info" | head -1)
              serial=$(sed -n 's/.*serial num *: *//p' <<<"$info" | head -1)
              echo "token: $label ($serial) via ''${module##*/}"

              alias=$requested_alias
              if ! alias=$(pick_alias "$module"); then
                echo "no certificate on the token" >&2
                token_hints
                exit 1
              fi
              echo "key:   $alias"

              config=$(mktemp)
              trap 'rm -f "$config"; unset APP_PKCS11_PIN' EXIT
              {
                echo "name=template-token"
                echo "library=$module"
                echo "slotListIndex=$slot"
              } >"$config"

              # apksigner instantiates SunPKCS11 through reflection, and JDK 17
              # does not export that package to the unnamed module. Only the
              # launcher's JDK_JAVA_OPTIONS accepts module options (not
              # JAVA_TOOL_OPTIONS).
              export JDK_JAVA_OPTIONS="''${JDK_JAVA_OPTIONS:-} --add-exports jdk.crypto.cryptoki/sun.security.pkcs11=ALL-UNNAMED"

              if [[ -z ''${pin:-} ]]; then
                pin=$(read_pin)
                if [[ -z ''${pin:-} ]]; then
                  echo "empty PIN" >&2
                  exit 1
                fi
                # The PIN goes through the environment of this one command, not
                # argv, and stays around for a retry with the other module.
                export APP_PKCS11_PIN=$pin
                unset pin
              fi

              echo "signing $apk (touch the key if it blinks)"
              # `--provider-class` installs SunPKCS11 in the JCA: without it the
              # KeyStore hands out a key that no provider can sign with
              # ("No installed provider supports this key").
              if output=$(apksigner sign \
                --ks NONE \
                --ks-type PKCS11 \
                --provider-class sun.security.pkcs11.SunPKCS11 \
                --provider-arg "$config" \
                --ks-key-alias "$alias" \
                --ks-pass env:APP_PKCS11_PIN \
                --key-pass env:APP_PKCS11_PIN \
                "$apk" 2>&1); then
                grep -v '^NOTE: Picked up JDK_JAVA_OPTIONS' <<<"$output" >&2 || true
                signed=1
                break
              fi

              grep -v '^NOTE: Picked up JDK_JAVA_OPTIONS' <<<"$output" >&2 || true
              # Never retry a rejected PIN: three failures block the card.
              if grep -qE 'FailedLoginException|CKR_PIN_INCORRECT|CKR_PIN_LOCKED' <<<"$output"; then
                token_hints
                exit 1
              fi
              if grep -q 'CKR_USER_NOT_LOGGED_IN' <<<"$output"; then
                cat >&2 <<'EOF'
          the token logged out between loading the key and signing it. Java's
          PKCS#11 provider cannot re-enter the PIN for every signature, which a
          key with PIN policy "always" demands (CKA_ALWAYS_AUTHENTICATE).
          `ykman piv keys info 9c` shows it; if it says "PIN required for use:
          ALWAYS", regenerate the signing key with --pin-policy once.
          EOF
              fi
              echo "''${module##*/} could not sign with this token; trying the next PKCS#11 module" >&2
            done

            if ((signed == 0)); then
              echo "could not sign with any PKCS#11 module" >&2
              token_hints
              exit 1
            fi
          else
            keystore=''${APP_KEYSTORE:-$HOME/.android/template-release.keystore}
            password=''${APP_KEYSTORE_PASSWORD:-template}

            if [[ ! -f $keystore ]]; then
              echo "creating keystore $keystore"
              mkdir -p "$(dirname "$keystore")"
              keytool -genkeypair -noprompt \
                -keystore "$keystore" \
                -storepass "$password" -keypass "$password" \
                -alias template -keyalg RSA -keysize 2048 -validity 10000 \
                -dname "CN=Template, O=Template, C=US"
            fi

            apksigner sign \
              --ks "$keystore" \
              --ks-pass "pass:$password" \
              --key-pass "pass:$password" \
              "$apk"
          fi

          apksigner verify --print-certs "$apk" | head -n 3
        '';

        buildApp = pkgs.writeShellScriptBin "template-build" ''
          set -euo pipefail
          out=''${1:-./template.apk}
          cp -f ${apkFor { }}/template.apk "$out"
          chmod u+w "$out"
          echo "wrote $out ($(du -h "$out" | cut -f1))"
          echo "it is signed with a throwaway build key;"
          echo "run 'nix run .#sign -- $out' to sign it with yours"
        '';

        installApp = pkgs.writeShellScriptBin "template-install" ''
          set -euo pipefail

          export PATH=${
            lib.makeBinPath [
              sdk.androidsdk
              jdk
            ]
          }:$PATH

          apk=''${1:-}
          if [[ -z $apk ]]; then
            apk=$(mktemp --suffix=.apk)
            cp ${apkFor { }}/template.apk "$apk"
            chmod u+w "$apk"
            trap 'rm -f "$apk"' EXIT
          fi

          # Always re-sign: the APK from the nix store uses a throwaway key.
          ${signScript}/bin/template-sign "$apk"

          devices=$(adb devices | awk 'NR > 1 && $2 == "device"' | wc -l)
          if [[ -z ''${ANDROID_SERIAL:-} && $devices -gt 1 ]]; then
            echo "more than one device is connected; pick one with ANDROID_SERIAL=<serial>" >&2
            adb devices >&2
            exit 1
          fi

          adb install -r "$apk"
          adb shell am start -n dev.serephus.template/android.app.NativeActivity
          echo "template installed and launched"
        '';

        runApp = pkgs.writeShellScriptBin "template-run" ''
          set -euo pipefail

          if [[ ! -f Cargo.toml ]]; then
            echo "run this from the project root (no Cargo.toml here)" >&2
            exit 1
          fi

          export PATH=${
            lib.makeBinPath [
              rust
              pkgs.cargo-apk
              sdk.androidsdk
              jdk
              pkgs.pkg-config
            ]
          }:$PATH
          export ANDROID_HOME=${androidHome sdk}
          export ANDROID_SDK_ROOT=${androidHome sdk}
          export ANDROID_NDK_ROOT=${ndkHome sdk}
          export ANDROID_NDK_HOME=${ndkHome sdk}

          # Build, install and start it, with logcat attached.
          exec cargo apk run --lib "$@"
        '';

        # A separate SDK composition: emulator + system image are ~1.5 GiB, so
        # they must not end up in the default dev shell.
        emulatorSdk = androidComposition {
          includeEmulator = true;
          includeSystemImages = true;
          systemImageTypes = [ "google_apis" ];
          abiVersions = [ "x86_64" ];
        };

        emulatorApp = pkgs.writeShellScriptBin "template-emulator" ''
          set -euo pipefail

          export PATH=${
            lib.makeBinPath [
              emulatorSdk.androidsdk
              jdk
            ]
          }:$PATH
          export ANDROID_HOME=${androidHome emulatorSdk}
          export ANDROID_SDK_ROOT=$ANDROID_HOME
          export ANDROID_USER_HOME=''${ANDROID_USER_HOME:-$HOME/.android}

          # A virtual device needs several GB; keep it next to the project so it
          # does not fill up a small home directory.
          if [[ -z ''${ANDROID_AVD_HOME:-} ]]; then
            if [[ -f Cargo.toml ]]; then
              ANDROID_AVD_HOME=$PWD/.android/avd
            else
              ANDROID_AVD_HOME=$ANDROID_USER_HOME/avd
            fi
          fi
          export ANDROID_AVD_HOME
          mkdir -p "$ANDROID_AVD_HOME"
          if [[ -f Cargo.toml ]]; then
            export TMPDIR=$PWD/.android/tmp
            mkdir -p "$TMPDIR"
          fi

          avd=''${APP_AVD:-template_api${androidSdkVersion}}
          image="system-images;android-${androidSdkVersion};google_apis;x86_64"

          if [[ -z ''${ANDROID_SERIAL:-} ]]; then
            if ! avdmanager list avd -c 2>/dev/null | grep -qx "$avd"; then
              echo "creating AVD '$avd' ($image) in $ANDROID_AVD_HOME"
              echo no | avdmanager create avd --force -n "$avd" -k "$image" -d pixel_6 >/dev/null
            fi

            # The Pixel 6 profile is 1080x2400 at 10 GB of user data; both are
            # more than needed, and a smaller surface keeps software rendering
            # responsive.
            config=$ANDROID_AVD_HOME/$avd.avd/config.ini
            if [[ -f $config ]]; then
              sed -i -E \
                -e 's/^disk\.dataPartition\.size *=.*/disk.dataPartition.size = 2G/' \
                -e 's/^hw\.lcd\.width *=.*/hw.lcd.width = 720/' \
                -e 's/^hw\.lcd\.height *=.*/hw.lcd.height = 1280/' \
                -e 's/^hw\.lcd\.density *=.*/hw.lcd.density = 320/' \
                "$config"
            fi

            echo "booting the emulator (the first start takes a minute)"
            # shellcheck disable=SC2086
            "$ANDROID_HOME/emulator/emulator" -avd "$avd" \
              -no-snapshot -no-boot-anim \
              ''${APP_EMULATOR_FLAGS:--gpu auto} &
            emulator_pid=$!
            trap 'kill $emulator_pid 2>/dev/null || true' EXIT

            # `adb wait-for-device` refuses to run when a phone is attached as
            # well, so poll for the emulator instead.
            serial=""
            for _ in $(seq 180); do
              serial=$(adb devices | awk '$1 ~ /^emulator-/ && $2 == "device" { print $1; exit }')
              [[ -n $serial ]] && break
              sleep 1
            done
            [[ -n $serial ]] || { echo "the emulator did not start" >&2; exit 1; }
          else
            serial=$ANDROID_SERIAL
          fi

          echo -n "waiting for Android to finish booting"
          until [[ "$(adb -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == 1 ]]; do
            echo -n "."
            sleep 2
          done
          echo

          # The APK is signed with a throwaway key that changes when the code
          # does, so upgrading over an older install fails; start clean then.
          if ! adb -s "$serial" install -r ${apkFor { target = "x86_64-linux-android"; }}/template.apk; then
            echo "installing failed (different signing key?), reinstalling from scratch"
            adb -s "$serial" uninstall dev.serephus.template >/dev/null 2>&1 || true
            adb -s "$serial" install ${apkFor { target = "x86_64-linux-android"; }}/template.apk
          fi
          adb -s "$serial" shell am start -n dev.serephus.template/android.app.NativeActivity
          echo "template is running on $serial; press Ctrl-C to shut the emulator down"

          if [[ -n ''${emulator_pid:-} ]]; then
            wait "$emulator_pid"
          fi
        '';

        apps' = {
          build = {
            type = "app";
            program = "${buildApp}/bin/template-build";
            meta.description = "Build a release APK and copy it to ./template.apk";
          };
          sign = {
            type = "app";
            program = "${signScript}/bin/template-sign";
            meta.description = "Sign an APK with your keystore or a PKCS#11 token (YubiKey)";
          };
          install = {
            type = "app";
            program = "${installApp}/bin/template-install";
            meta.description = "Sign the APK with your key, install it on the connected phone and launch it";
          };
          run = {
            type = "app";
            program = "${runApp}/bin/template-run";
            meta.description = "Debug build from this checkout, installed and started on the connected phone";
          };
          default = {
            type = "app";
            program = "${buildApp}/bin/template-build";
            meta.description = "Build a release APK and copy it to ./template.apk";
          };
        };

        devShell = pkgs.mkShell {
          name = "android-egui";

          packages = [
            rust
            pkgs.cargo-apk
            sdk.androidsdk # adb, sdkmanager, aapt2, apksigner, ...
            jdk # keytool, for the signing keystore
            pkgs.pkg-config
          ]
          # Only needed to run the app natively during development.
          ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            pkgs.libGL
            pkgs.libxkbcommon
            pkgs.wayland
            pkgs.libx11
            pkgs.libxcursor
            pkgs.libxi
            pkgs.libxrandr
          ];

          env = {
            ANDROID_HOME = androidHome sdk;
            ANDROID_SDK_ROOT = androidHome sdk;
            ANDROID_NDK_ROOT = ndkHome sdk;
            ANDROID_NDK_HOME = ndkHome sdk;
          }
          // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
            LD_LIBRARY_PATH = lib.makeLibraryPath [
              pkgs.libGL
              pkgs.libxkbcommon
              pkgs.wayland
              pkgs.libx11
              pkgs.libxcursor
              pkgs.libxi
              pkgs.libxrandr
            ];
          };

          shellHook = ''
            # aapt2, apksigner, zipalign, ... are handy to have on PATH.
            export PATH="${buildTools sdk}:$PATH"
            export ANDROID_AVD_HOME="$PWD/.android/avd"

            echo "android-egui dev shell"
            echo "  rust:    $(rustc --version)"
            echo "  sdk:     $ANDROID_HOME"
            echo "  ndk:     $ANDROID_NDK_HOME"
            if command -v adb >/dev/null; then
              echo "  devices: $(adb devices | tail -n +2 | grep -c 'device$' || true)"
            fi
          '';
        };
      in
      {
        devShells.default = devShell;
        formatter = pkgs.nixfmt;

        packages =
          let
            apk = apkFor { };
          in
          {
            inherit apk;
            default = apk;
            # x86_64 build, used by `nix run .#emulator`.
            apk-x86_64 = apkFor { target = "x86_64-linux-android"; };
          };

        # The emulator is x86_64-only, so that app is only exposed there.
        apps =
          apps'
          // lib.optionalAttrs (system == "x86_64-linux") {
            emulator = {
              type = "app";
              program = "${emulatorApp}/bin/template-emulator";
              meta.description = "Boot an Android emulator (x86_64), install the app and launch it";
            };
          };
      }
    );
}
