# nixpkgs

To build:

```bash
nix build .#darwinConfigurations.shed.system --extra-experimental-features 'nix-command flakes'
```

To install:

```bash
./result/sw/bin/darwin-rebuild switch --flake ".#shed"
```

To update:
```bash
nix flake update --flake . --extra-experimental-features 'nix-command flakes'
```
