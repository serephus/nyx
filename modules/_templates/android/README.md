# Android template

Kotlin + Jetpack Compose Android app scaffold. The Nix flake provides the JDK, the
Android SDK and Gradle, so the only host requirement is Nix with flakes enabled.

## Create a project

```console
nix flake new -t github:serephus/nyx#android myapp
cd myapp
direnv allow   # or: nix develop
```

## Toolchain

| Component | Version |
| --- | --- |
| JDK | 21 |
| Gradle | 8.14.4 (nixpkgs `gradle_8`) |
| Android Gradle Plugin | 8.13.2 |
| Kotlin | 2.2.21 |
| compileSdk / targetSdk | 36 |
| minSdk | 26 |
| Compose BOM | 2025.12.01 |

There is no Gradle wrapper. Everything runs the Gradle from this flake, so nothing
is downloaded from `services.gradle.org`. Keep `platformVersions` /
`buildToolsVersions` in `flake.nix`, `gradle/libs.versions.toml` and
`app/build.gradle.kts` (`compileSdk`, `buildToolsVersion`) in sync when bumping
any of these.

## Common commands

Inside `nix develop`:

```console
gradle assembleDebug         # build the debug APK
gradle installDebug          # install on a connected device/emulator
gradle lintDebug
gradle testDebugUnitTest
```

Or through the flake apps (they locate the repo root, so they work from any
subdirectory):

```console
nix run .#apk       # assembleDebug
nix run .#install   # installDebug
nix run .#lint
nix run .#test
nix run .#release   # assembleRelease
nix run .#clean
```

`.#apk` is the default app, so `nix run .` builds the debug APK.

> The apps shell out to Gradle outside the Nix sandbox. Nixpkgs no longer provides
> `buildGradleAndroidApplication`, and a reproducible offline Gradle build would
> require vendoring every Maven artifact.

## NixOS notes

The dev shell exports
`GRADLE_OPTS=-Dorg.gradle.project.android.aapt2FromMavenOverride=$ANDROID_HOME/build-tools/36.0.0/aapt2`
because the aapt2 binary that AGP downloads from Maven is built for generic Linux
and cannot run on NixOS.

If you invoke Gradle outside the dev shell (for example from Android Studio, which
also needs to be pointed at the Nix Gradle instead of a wrapper), set the same
property yourself.

## Emulator

```console
nix develop .#emulator
avdmanager create avd -n template -k "system-images;android-36;google_apis_playstore;x86_64"
emulator -avd template
```

The emulator shell is only exposed on x86_64 hosts. Hardware acceleration needs
`/dev/kvm` (add your user to the `kvm` group on NixOS).

## Renaming the app

Replace `dev.serephus.template` with your own id/namespace in:

- `app/build.gradle.kts` (`namespace`, `applicationId`)
- `app/src/main/kotlin/dev/serephus/template/` (move the directory)
- `app/src/test/kotlin/`
- `app/src/main/res/values/strings.xml` (`app_name`)

The project name lives in `settings.gradle.kts` (`rootProject.name`).

## Dependencies

All versions are in `gradle/libs.versions.toml`. Add an entry there and reference
it as `libs.<alias>` in `app/build.gradle.kts`. Dependabot updates Gradle,
GitHub Actions and Nix inputs weekly.

## Repository settings

The flake also declares the GitHub repository itself through
[nixit](https://github.com/serephus/nixit) (`githubRepositories.android`):
description, topics, visibility, merge/auto-merge policy, rulesets and Actions
defaults. The `pr` ruleset requires a status check named `build`, which is why the
CI job carries that exact name.

## Signing

Debug builds work out of the box. For release builds create `keystore.properties`
in the project root (gitignored):

```properties
storeFile=release.jks
storePassword=...
keyAlias=...
keyPassword=...
```

Without it, `assembleRelease` falls back to the debug signing key. That is fine for
local testing but not for publishing.

## Layout

```text
flake.nix                  # devShells (default, emulator), apps, GitHub repo settings
flake.lock                 # nixpkgs, flake-utils, nixit pins
app/build.gradle.kts       # Android module, signing, dependencies
gradle/libs.versions.toml  # version catalog
app/src/main/kotlin/       # Compose UI (MainActivity, Greeting, theme)
app/src/test/              # JVM unit tests
```
