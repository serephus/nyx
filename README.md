# nyx

My NixOS configs written from scratch with den.

## Install with nixos-anywhere

```console
nix run nixpkgs#nixos-anywhere -- --option substituters "https://mirrors.ustc.edu.cn/nix-channels/store" --option trusted-substituters "https://mirrors.ustc.edu.cn/nix-channels/store" --build-on local --no-substitute-on-destination --flake .#<host> -L <target>
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

```console
nix run .#vm
```
