# nyx

My NixOS configs written from scratch with [den](https://github.com/denful/den).

## Install with nixos-anywhere

```console
# If you want to try my config:
# Boot a VM or bare metal machine with a NixOS live USB, then install it with
# nixos-anywhere over SSH.
# Replace github:serephus/nyx with your remote/local repository, then replace
# <host> and <target> according to your case.
# Adapt one of the existing host configs to your hardware:
# disk device/encryption, hardware imports, monitors, and other
# hardware-specific settings.
# Replace the root and user hashedPassword values and SSH keys with your
# own credentials.
# My Vaultix secrets will not decrypt without my YubiKey, this mainly means
# the xray service will not start.
# Review other personal configs before trying this configuration.
nix run nixpkgs#nixos-anywhere -- \
  --option substituters "https://mirrors.ustc.edu.cn/nix-channels/store" \
  --option trusted-substituters "https://mirrors.ustc.edu.cn/nix-channels/store" \
  --build-on local \
  --no-substitute-on-destination \
  --flake github:serephus/nyx#<host> \
  <target>
```

## Build the installation iso

```console
nix build .#iso
```

## Build

```console
# default action is build
nix run .#nyx

# pass any other nh action
nix run .#nyx -- switch
```

## Run the VM

If you want to try my config and have a working NixOS environment:

```console
# runs host nyx
nix run .#vm
```
