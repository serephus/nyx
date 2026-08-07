# nyx

My NixOS configs written from scratch with den.

```console
nix flake update
```

- Build

```console
# default action is build
nix run .#nyx

# pass any other nh action
nix run .#nyx -- switch
```

- Run the VM

```console
nix run .#vm
```
