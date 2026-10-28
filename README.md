# nix-config

My NixOS configuration using flakes, Home Manager, and a modular architecture.
Heavily inspired by [Misterio77's nix-config](https://github.com/Misterio77/nix-config).

## Hosts

| Host | Hardware | Role |
|------|----------|------|
| `tau` | HP Omen laptop | Workstation: GNOME + Niri, NVIDIA, gaming, backups |
| `lyr` | Intel N100 mini PC | Home server: Immich, OpenCode, Caddy, backups |
| `dra` | Desktop PC | Workstation/server: GNOME + Niri, AMD, gaming, llama.cpp, Restic |
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

## What This Flake Includes

- **Multi-host NixOS and Home Manager** — shared global modules, opt-in features, per-host hardware and user configurations, overlays, and custom packages
- **Provisioning and deployment** — declarative disk layouts with [disko](https://github.com/nix-community/disko), remote installation through [nixos-anywhere](https://github.com/nix-community/nixos-anywhere), and a custom installer ISO
- **GitOps deployment** — [Comin](https://github.com/nlewo/comin) polls the private repository on each host; `main` switches that host's configuration, while `testing-<host>` tests it
- **Builds and shared binary cache** — a git hook builds the configurations before push, with builds offloaded to remote builders and stored in the central [Harmonia](https://github.com/nix-community/harmonia) Nix cache, so the built configuration is already in the store when each host pulls
- **Desktop environments** — GNOME and [niri](https://github.com/YaLTeR/niri), with DankMaterialShell/Noctalia, gaming, GPU, printing, and desktop application modules
- **Self-hosted services** — reusable modules for Caddy, Immich, Jellyfin, Minecraft, Miniflux, Calibre, Nixarr, Restic, OpenCode, Ollama, llama.cpp, and other containerized services
- **Backups** — Restic client/server modules, local and off-site repositories, aggregated system/service/user paths, database dumps, retention policies, and SOPS-managed credentials
- **Secrets and private values** — encrypted secrets with [sops-nix](https://github.com/Mic92/sops-nix), Age keys derived from SSH host keys, and a filtered public branch for non-secret sensitive values
- **Networking** — Tailscale and ZeroTier clients, Caddy with Cloudflare DNS challenges, firewall rules, and Wake-on-LAN
- **Development environment** — [devenv](https://devenv.sh/) provides the Nix language server, formatter, flake checks, pre-commit hooks, secret-management tools, and repository scripts
- **Consistent theming** — [Stylix](https://github.com/danth/stylix) and Catppuccin across system and Home Manager applications

## Favorite Tools

I like modern, opinionated tools with sensible defaults and strong terminal integration. My workflow is built around [Fish](https://fishshell.com/), [Starship](https://starship.rs/), [Zellij](https://zellij.dev/), [Yazi](https://yazi-rs.github.io/), [Helix](https://helix-editor.com/), [Zed](https://zed.dev/), and [OpenCode](https://opencode.ai/), complemented by CLI utilities such as [bat](https://github.com/sharkdp/bat), [eza](https://github.com/eza-community/eza), [fd](https://github.com/sharkdp/fd), [ripgrep](https://github.com/BurntSushi/ripgrep), ripgrep-all, [fzf](https://github.com/junegunn/fzf), [zoxide](https://github.com/ajeetdsouza/zoxide), [dust](https://github.com/bootandy/dust), [sd](https://github.com/chmln/sd), tldr, navi, HTTPie, and [btop](https://github.com/aristocratos/btop).

## Development

Enter the devenv shell through direnv or directly with Nix:

```bash
direnv allow
# or
nix develop
```

If flakes are not enabled yet, `shell.nix` provides a bootstrap shell using the pinned nixpkgs from `flake.lock`:

```bash
nix-shell
```

## Deployment

Each host polls the private Git repository with Comin. The `main` branch switches that host's NixOS configuration; `testing-<host>` runs it with the `test` operation.

To install a host, boot it from the custom installer ISO (written to USB or booted over the network). The installer enables SSH access as `root` for the configured public key. Then run `deploy-host <hostname>` from this repository: the script invokes [nixos-anywhere](https://github.com/nix-community/nixos-anywhere), generates the host's hardware configuration, and applies that host's [disko](https://github.com/nix-community/disko) partition layout. A custom installer ISO can be built from the `installer` configuration.

```bash
deploy-host <hostname>
build-iso
```

## Secrets

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix), encrypted with Age keys derived from SSH host keys.

```bash
# Edit shared secrets or a host-specific secret file
sops nixos/hosts/common/secrets.yaml
sops nixos/hosts/<host>/secrets.yaml

# After adding a new key, re-encrypt
sops updatekeys nixos/hosts/common/secrets.yaml
sops updatekeys nixos/hosts/<host>/secrets.yaml

# Convert SSH host key to Age
ssh-to-age -i nixos/hosts/<host>/ssh_host_ed25519_key.pub
```

## Sensitive Data

Workaround for non-secret but private values (domain, emails, names, IDs) that end up in `/nix/store` — harmless but better kept out of the public repo.

These values are centralized in `sensitive.nix` as a NixOS module and configuration. `sync-public-repo` uses [git-filter-repo](https://github.com/newren/git-filter-repo) to create the filtered `public` mirror, removing `sensitive.nix`, encrypted `secrets.yaml` files, and SSH host public keys before pushing.

```bash
sync-public-repo     # requires public-remote
```
