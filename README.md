# nyx

My NixOS configs written from scratch with [den](https://github.com/denful/den).

## Add flake inputs

1. Declare the input with `flake-file.inputs.<name>` in any module under `modules/`
   (see `modules/disko.nix` or `modules/vaultix.nix` for examples).
2. Run `nix run .#write-flake` to regenerate `flake.nix`.

## Build

```console
# default action is build
nix run .#nyx

# pass any other nh action
nix run .#nyx -- switch
```

## Add a new host

Hosts live in `modules/<host>.nix` (e.g. `modules/nyx.nix`), each defining a `den.aspects.<host>`.
To add a machine:

1. Copy an existing host aspect (`nyx.nix`/`x1c.nix` for laptops, `nova.nix` for desktops) and
   adapt the hardware-specific bits: disk device/encryption in the disko aspects (`device`,
   `encrypted`, `fido2`, `swapSize`), hardware `imports`, `kernelModules`, monitors, etc.
2. Register the host in `modules/hosts.nix`:
   `den.hosts.x86_64-linux.<host>.users.<user> = { };`
   (define a new `den.aspects.<user>` too if this isn't an existing user)
3. Update secrets:
   1. Add the host to the Vaultix node map in `modules/vaultix.nix` so it becomes a secret
      recipient.
   2. Set `hostPubKey` in the aspect to the machine's real SSH host public key. Vaultix encrypts
      every secret to that key and decrypts it on the target with `/etc/ssh/ssh_host_ed25519_key`,
      so the key must exist and match before any secret is available (see "Bootstrapping" below).
   3. Re-encrypt the secrets for the new recipient: `nix run .#vaultix.app.x86_64-linux.renc`
4. If you added flake inputs, regenerate `flake.nix` (it is auto-generated, don't edit it by
   hand): `nix run .#write-flake`
5. Sanity-check before deploying: `nix flake check` (it evaluates every host config).

## Bootstrapping a fresh machine

Vaultix decrypts secrets on the target at boot with the machine's SSH host key
(`vaultix-activate` runs before `sysinit.target`). A brand-new machine therefore cannot decrypt
anything until its host key exists and matches the `hostPubKey` baked into the aspect:

1. Install with the secrets temporarily commented out or replaced with plain values, so the
   first boot works without decryption. The root/user `hashedPasswordFile` lines in
   `modules/user/root.nix` and `modules/user/serephus.nix` are the usual suspects.
2. Boot the installed machine and grab its host public key (e.g. `ssh-keyscan <host>`), then
   put it into the aspect's `hostPubKey` (step 3.2 above).
3. Re-encrypt: `nix run .#vaultix.app.x86_64-linux.renc`, commit the regenerated
   `secrets/cache/` files, then rebuild and switch. Once decryption works, restore the
   commented-out secrets.

## Build the installation iso

```console
nix build .#iso
```

## Install with nixos-anywhere

If you want to try my config: Boot a VM or bare metal machine with a NixOS live USB, then
install it with nixos-anywhere over SSH.

Adapt one of the existing host configs to your hardware: disk device/encryption, hardware
imports, monitors, and other hardware-specific settings. Replace the root and user
hashedPassword values and SSH keys with your own credentials. My Vaultix secrets will not
decrypt without my YubiKey, so you'll have to replace or remove those — this won't stop the
system from building. Review other personal configs before trying this configuration.

```console
# replace github:serephus/nyx with your remote/local repository, then
# replace <host> and <target> according to your case.
nix run nixpkgs#nixos-anywhere -- \
  --option substituters "https://mirrors.ustc.edu.cn/nix-channels/store" \
  --option trusted-substituters "https://mirrors.ustc.edu.cn/nix-channels/store" \
  --build-on local \
  --no-substitute-on-destination \
  --flake github:serephus/nyx#<host> \
  <target>
```

## Run the VM

```console
# runs host nyx
nix run .#vm
```
