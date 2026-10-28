# Repository Guidelines

NixOS flake for several personal hosts, structured after [Misterio77's nix-config](https://github.com/Misterio77/nix-config). Home Manager runs as a NixOS module.

Read the code for specifics (inputs, hosts, packages, services); this file only covers conventions and things that are easy to get wrong.

## Deployment Is Automatic

Hosts run [comin](https://github.com/nlewo/comin) against the private GitHub remote:

- A push to `main` is **switched on every host**.
- A push to `testing-<host>` is applied with `test` (not persisted across reboot) on that host only.

Treat pushing as deploying. Never push unless asked; prefer a `testing-<host>` branch for risky changes.

## The Working Tree Is Shared

`~/Projects` is synced with Syncthing between hosts, so this checkout (including `.git`) is the same live copy on every host. Edits and deletions propagate immediately, and anything linked into the repo with `mkOutOfStoreSymlink` changes on all hosts at once. Migrate hosts before deleting or reshaping such files.

## Layout

- `nixos/hosts/<host>/` — per-host config, disk layout, hardware, host secrets.
- `nixos/hosts/common/global/` — imported by every host.
- `nixos/hosts/common/optional/` — opt-in modules, imported explicitly by hosts.
- `nixos/hosts/common/users/<user>/` — ties a NixOS account to its Home Manager config.
- `home-manager/users/<user>/<host>.nix` — per-host HM entry point, composed from `global/` and `features/`.
- `modules/`, `overlays/`, `pkgs/` — reusable modules, overrides, custom packages. `pkgs.stable` / `pkgs.unstable` come from overlays.
- `scripts/` — devenv scripts (host bootstrap, ISO build, public repo sync).

New functionality usually belongs in a small, focused module under `common/optional/` (or an HM feature) that hosts import, not inline in a host file.

## Sensitive Data & Public Mirror

- Personal values (domain, emails, names, device IDs) live **only** in `nixos/hosts/common/global/sensitive.nix` and are read via `config.sensitive.*`. Never hardcode them elsewhere.
- A filtered `public` branch is produced by `sync-public-repo`; a pre-push hook blocks pushing real values there.
- Secrets use sops-nix (`secrets.yaml` per host and in `common/`). Never write or commit decrypted content. Edit with `sops <file>`; after changing keys in `.sops.yaml`, run `sops updatekeys` on the affected files.

## Binary Caches & Trust

- Adding a substituter means trusting whoever can push to it with root on every host that uses it. Don't add caches (in modules or in flake `nixConfig`) without asking.
- Hosts share builds through a self-hosted cache and SSH remote builders (`myHosts`, `distributed-builds.nix`). Anything in the cache host's store gets re-signed with our own key, so third-party content fetched there becomes "trusted" for every host.

## Commands

- Dev shell: `direnv allow` or `nix develop` (devenv; provides sops, age, disko, nixos-anywhere, nixd).
- Format: `nix fmt`.
- Check: `nix flake check` (builds every host for the current system; `--no-build` to evaluate only).
- Build one host: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.
- Apply locally: `nh os switch`, or `nh os test` for risky changes.

Git hooks (formatting, whitespace, flake check on pre-push) are installed by the dev shell.

## Adding a Host

Create `nixos/hosts/<host>/`, run `deploy-host <host>` (generates host keys and prints the Age key), add that key to `.sops.yaml` and run `sops updatekeys`, register the host in `flake.nix` and `myHosts`, and add `home-manager/users/<user>/<host>.nix`.

## Conventions

- Lowercase, hyphenated names for hosts, users and module files.
- `stateVersion` is per host; never change it casually.
- Commits: short imperative summary with a scope, no trailing period (e.g. `home: set default shell`, `pkgs: foo 1.0 -> 1.1`).
