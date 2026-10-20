# Android egui template

Rust + [egui]/[eframe] Android app scaffold. The app is a `NativeActivity` whose
whole UI is Rust — no Kotlin, no Gradle, no Android Studio. `cargo-apk` packages
the shared library into an APK, and the Nix flake provides Rust (with the Android
targets), the SDK, the NDK and every tool around them.

The same `src/` runs as a normal desktop window, which is how you develop it.

## Create a project

```console
nix flake new -t github:serephus/nyx#android-egui myapp
cd myapp
direnv allow   # or: nix develop
nix build .#apk
```

## Toolchain

| Component | Version |
| --- | --- |
| Rust | stable (rust-overlay), `aarch64`/`armv7`/`x86_64` Android std |
| eframe / egui | 0.32 |
| cargo-apk | from nixpkgs |
| Android SDK | 35 |
| Build tools | 36.0.0 |
| NDK | r28c (28.2.13676358) |
| JDK | 21 |
| compileSdk / targetSdk | 35 |
| minSdk | 26 |

Keep `androidSdkVersion`, `buildToolsVersion` and `ndkVersion` in `flake.nix` in
sync with `[package.metadata.android]` in `Cargo.toml`.

`compileSdk` is 35 rather than the newest 36 because `cargo apk` (via
`ndk-build`) only accepts SDK platforms up to the NDK's `NDK_MAX_PLATFORM_LEVEL`,
which is 35 for NDK r28 *and* r29 — a newer platform is ignored and cargo-apk
stops with "Android SDK has no platforms installed". Bump `androidSdkVersion`
(and `target_sdk_version`) once a newer NDK supports it. Build tools are
independent of that, so they stay on 36.

## Common commands

Inside `nix develop`:

```console
cargo run                  # desktop window, fast iteration
cargo test                 # UI tests, no device needed
cargo fmt --check
cargo clippy --all-targets

cargo apk run --lib        # debug build on the connected phone, with logcat
```

`--lib` matters: the crate is a `cdylib` (Android loads it as a shared library)
and `cargo apk` would otherwise also try the desktop binary target.

Or through the flake apps, which need no shell:

```console
nix run .#build            # release APK -> ./template.apk (throwaway signing key)
nix run .#sign -- app.apk  # re-sign with your key
nix run .#install          # sign with your key, install and launch on the phone
nix run .#emulator         # boot an AVD, install the x86_64 APK and launch it
```

`.#build` is the default, so `nix run .` produces an APK.

| Variable | Used by | Meaning |
| --- | --- | --- |
| `ANDROID_SERIAL` | `install`, `run`, `emulator` | Pick a device when several are attached |
| `APP_KEYSTORE` / `APP_KEYSTORE_PASSWORD` | `sign`, `install` | Keystore (default `~/.android/template-release.keystore`) |
| `APP_PKCS11_PIN` / `APP_PKCS11_LIB` | `sign`, `install` | Sign with a PKCS#11 token (YubiKey) |
| `APP_AVD`, `APP_EMULATOR_FLAGS` | `emulator` | AVD name, extra emulator flags |

## How it fits together

```text
flake.nix              dev shell (rust + SDK + NDK + cargo-apk), packages, apps
Cargo.toml             crate + [package.metadata.android] (manifest, signing)
src/lib.rs             desktop entry, android_main, back button, JNI helpers
src/app.rs             the egui UI, plus headless tests
src/main.rs            desktop binary
```

- `src/lib.rs` builds a `cdylib`. Android's `NativeActivity` loads it and calls
  `android_main`, which hands the `AndroidApp` to winit/eframe.
- The manifest, package id, label, theme, permissions and SDK levels all come
  from `[package.metadata.android]`; `cargo apk` generates the manifest from it.
  `aapt dump badging result/template.apk` shows the result.
- The back button is handled in `src/app.rs`: a `NativeActivity` swallows
  `KEYCODE_BACK`, but winit reports it as `Key::BrowserBack`, and the app then
  calls `Activity.finish()` (see `src/lib.rs`).
- The screen is kept awake while the app is in the foreground (`keep_screen_on` in
  `src/lib.rs`); remove that call if your app should be allowed to sleep.
- Quitting ends the process on purpose. winit can create only one event loop per
  process and Android reuses cached processes, so an app that survived its
  Activity could never be opened again (`EventLoop can't be recreated`).
- `packages.apk` builds hermetically from `Cargo.lock` and is cacheable; it is
  signed with a throwaway key, so `sign`/`install` re-sign before use.
- The emulator has its own SDK composition, so the ~1.5 GiB system image never
  lands in the dev shell. The AVD lives in `./.android/avd`.

## Renaming the app

The template uses `dev.serephus.template` / `template` everywhere. Replace both in:

- `Cargo.toml`: `package`, `apk_name`, `[lib] name`, `[[bin]] name`,
  `[package.metadata.android] label`
- `flake.nix`: `dev.serephus.template` in `install`/`emulator`, `template.apk`
  in `build`/`install`/`emulator`, and the `APP_*` variable names if you like
- `src/lib.rs`, `src/app.rs`, `src/main.rs`: the crate is referred to by name in
  `src/main.rs` (`template::run_desktop()`), and the window/log tags say
  "Template"

Changing the package id after installing the app means uninstalling it first,
because Android treats it as a different app.

## Signing

`nix run .#sign` creates `~/.android/template-release.keystore` (password
`template`) on first use. Keep it: Android only accepts updates signed with the
same key. Override with `APP_KEYSTORE` / `APP_KEYSTORE_PASSWORD`.

For a key that cannot be copied off the device, use a YubiKey (PIV slot 9c):

```console
$ nix shell nixpkgs#yubikey-manager
$ ykman piv keys generate --algorithm RSA2048 9c pubkey.pem
$ ykman piv certificates generate --subject "CN=Template upload" 9c pubkey.pem

$ APP_PKCS11_PIN=123456 nix run .#sign -- ./template.apk
```

`template-sign --help` lists the knobs (`APP_PKCS11_LIB`, `APP_PKCS11_SLOT`,
`APP_PKCS11_ALIAS` for tokens with several keys). If the slot's touch policy is
`always`, `apksigner` signs three times (v1, v2, v3), so expect a few touches.

Note that Google Play wants an **AAB**, not an APK, for new apps; this template
produces APKs. Signing an AAB with the same key works (`jarsigner` + the same
PKCS#11 module), but producing the bundle needs a Gradle/bundletool step.

## Emulator

```console
nix run .#emulator
```

The first run downloads the emulator and a system image (~1.5 GiB), creates the
AVD in `./.android/avd` and shrinks it to 720×1280 (the Pixel 6 default of
1080×2400 is slow to render in software). `/dev/kvm` must exist; add `-no-window`
to `APP_EMULATOR_FLAGS` for a headless run.

[egui]: https://github.com/emilk/egui
[eframe]: https://github.com/emilk/egui/tree/main/crates/eframe
