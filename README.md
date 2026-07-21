# nix-config

My NixOS configuration using flakes, Home Manager, and a modular architecture.
Heavily inspired by [Misterio77's nix-config](https://github.com/Misterio77/nix-config).

## Hosts

| Host | Hardware | Role |
|------|----------|------|
| `tau` | HP Omen laptop | Desktop, GNOME + Niri, NVIDIA, gaming |
| `lyr` | Intel N100 mini PC | Home server (Immich, Minecraft, Miniflux, Calibre, ...) |
| `dra` | Desktop PC | Desktop, GNOME, gaming + home server (restic) |
| `installer` | — | Custom NixOS installer ISO |

## Structure

```
flake.nix                    # Inputs and outputs
nixos/
  hosts/
    <host>/                  # Per-host configuration
      default.nix
      disk-config.nix        # disko partitioning
      hardware-configuration.nix
    common/
      global/                # Applied to all hosts
      optional/              # Opt-in modules (DE, servers, gaming, ...)
      users/                 # Per-user NixOS config
home-manager/
  users/
    <user>/
      global/                # Applied to all hosts
      <host>.nix             # Host-specific HM config
      features/              # Opt-in HM features (cli, desktop, backup, ...)
modules/                     # Custom NixOS and HM modules
overlays/                    # nixpkgs overlays
pkgs/                        # Custom packages
```

## Key Features

- **[home-manager](https://github.com/nix-community/home-manager)** — user environment as a NixOS module
- **[disko](https://github.com/nix-community/disko)** — declarative disk partitioning with LUKS encryption
- **[sops-nix](https://github.com/Mic92/sops-nix)** — secrets management
- **[stylix](https://github.com/danth/stylix)** — system-wide theming
- **[niri](https://github.com/YaLTeR/niri)** — scrollable-tiling Wayland compositor (via [niri-flake](https://github.com/sodiboo/niri-flake))

## Bootstrap

This is a standard Nix flake. If you don't have flakes enabled yet, `shell.nix` provides a bootstrap shell using the pinned nixpkgs from `flake.lock`:

```bash
nix-shell
```

If your nix already supports flakes:

```bash
nix develop
```

The repo also uses `devenv.nix` for some development utilities.

## Secrets

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix), encrypted with Age keys derived from SSH host keys.

```bash
# Edit secrets
sops nixos/hosts/<host>/secrets.yaml

# After adding a new key, re-encrypt
sops updatekeys nixos/hosts/<host>/secrets.yaml

# Convert SSH host key to Age
ssh-to-age -i nixos/hosts/<host>/ssh_host_ed25519_key.pub
```

## Sensitive Data

Workaround for non-secret but private values (domain, emails, names, IDs) that end up in `/nix/store` — harmless but better kept out of the public repo.

Centralized in `sensitive.nix` (NixOS module + config). The `public` branch is a filtered mirror — `sync-public-repo` strips these before pushing.

```bash
sync-public-repo     # requires public-remote
```

