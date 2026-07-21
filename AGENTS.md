# Repository Guidelines

NixOS flake config, heavily inspired by [Misterio77's nix-config](https://github.com/Misterio77/nix-config).

## Project Structure & Module Organization

- `flake.nix` defines inputs (nixpkgs variants, home-manager, niri-flake, disko, sops-nix) and outputs (packages, overlays, nixos/home modules, host configs).
- `nixos/hosts/<host>/` holds per-host configs plus `disk-config.nix`, `hardware-configuration.nix`, and `secrets.yaml`; shared pieces live in `nixos/hosts/common/{global,optional,users}/`.
- `home-manager/users/<user>/` contains per-user global defaults and host-specific files (e.g., `mood/tau.nix`).
- `modules/`, `overlays/`, and `pkgs/` expose reusable modules, package overrides, and custom packages.
- `devenv.nix` configures the development shell (tools, LSP, pre-commit hooks); `.sops.yaml` governs Age keys for secrets.

### Module System

- **Global modules** (`common/global/`) are imported by all hosts automatically.
- **Optional modules** (`common/optional/`) are imported selectively per host.
- **User modules** (`common/users/<user>/`) tie NixOS accounts to Home Manager configs.
- **Home Manager features** (`features/`) are composable units (cli, desktop, backup, hacking).

Home Manager runs as a NixOS module. User configs are linked per host:
```nix
home-manager.users.${user} =
  import "${inputs.self}/home-manager/users/${user}/${config.networking.hostName}.nix";
```

### Overlays

- `additions` — custom packages from `pkgs/`
- `modifications` — package overrides
- `unstable-packages` / `stable-packages` — accessible via `pkgs.unstable` / `pkgs.stable`

## Development, Build & Test Commands

- Enter dev shell: `direnv allow` (recommended) or `nix develop`.
- Format Nix code: `nix fmt` (uses `nixfmt-tree`).
- Evaluate and lint flake: `nix flake check`.
- Build a host without switching: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.
- Apply to the current machine: `nh os switch` (preferred) or `sudo nixos-rebuild switch --flake .#<host>`.
- Home Manager only: `nh home switch`.

Dev shell includes: `sops`, `ssh-to-age`, `age`, `disko`, `nixos-anywhere`, `nixd` (LSP).
Pre-commit hooks enforce: `nixfmt-rfc-style`, flake check, no trailing whitespace.

## Deployment

```bash
deploy-host <hostname>   # interactive: SSH keys, Age key, VM test, nixos-anywhere
build-iso                # build custom installer ISO
```

### Adding a New Host

1. Create `nixos/hosts/<hostname>/` with `default.nix` and `disk-config.nix`.
2. Run `deploy-host <hostname>` → generates SSH host keys, outputs Age public key.
3. Add Age key to `.sops.yaml` under `&hosts` and create a creation rule for host secrets.
4. Run `sops updatekeys` on all `secrets.yaml` files.
5. Add `nixosConfigurations.<hostname>` entry in `flake.nix`.
6. Create `home-manager/users/<user>/<hostname>.nix`.

## Coding Style & Naming Conventions

- Keep Nix expressions formatted by `nix fmt`; favor 2-space indentation and one attribute per line in sets.
- Name hosts, users, and module files in lowercase with hyphens/underscores (e.g., `nixos/hosts/dra`, `common/optional/restic-client.nix`).
- Keep modules focused; prefer small reusable optional modules under `nixos/hosts/common/optional/`.

## Testing Guidelines

- Run `nix flake check` before committing; catches evaluation errors and style issues.
- For risky changes, run `nixos-rebuild test --flake .#<host>` to stage without switching.
- Dry-run HM changes: `nh home switch --dry-run`.

## Secrets & Configuration Safety

- Secrets are encrypted with `sops-nix`; **never commit decrypted files**.
- Edit via `sops nixos/hosts/common/secrets.yaml` or `sops nixos/hosts/<host>/secrets.yaml`.
- After adding keys: `sops updatekeys nixos/hosts/common/secrets.yaml` and the per-host file.
- Convert SSH host keys to Age: `ssh-to-age -i nixos/hosts/<host>/ssh_host_ed25519_key.pub`.
- Secrets flow: SSH host key → Age key → `.sops.yaml` → encrypted `secrets.yaml` → decrypted at boot by sops-nix.

## Important Notes

- `stateVersion` is set per host; changing it requires careful migration.
- Nix channels are disabled; all inputs come from the flake.
- Garbage collection is manual (`nh clean`); store optimization runs daily at 20:30.
- User passwords are managed via sops (immutable users).

## Commit & Pull Request Guidelines

- Short, imperative summaries with optional scope (e.g., `home: set default shell`, `nixos: update gaming.nix`); no trailing period.
- In PRs, list affected hosts/users, commands run, and whether secrets or Age keys changed.
- Include brief context for functional changes and link related issues or deployment notes.
