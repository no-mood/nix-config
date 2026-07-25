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

New hosts can be tested and provisioned remotely with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) through the interactive deployment script. A custom installer ISO can also be built from the `installer` configuration.

```bash
deploy-host <hostname>
build-iso
```

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

These values are centralized in `sensitive.nix` as a NixOS module and configuration. `sync-public-repo` uses [git-filter-repo](https://github.com/newren/git-filter-repo) to create the filtered `public` mirror, removing `sensitive.nix`, encrypted `secrets.yaml` files, and SSH host public keys before pushing.

```bash
sync-public-repo     # requires public-remote
```
