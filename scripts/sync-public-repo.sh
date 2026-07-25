#!/usr/bin/env bash
# Sync the public branch in an isolated worktree: squash main, filter, push.
set -euo pipefail

if ! git remote get-url public-remote &>/dev/null; then
  echo "ERROR: remote 'public-remote' not found. Add it with:"
  echo "  git remote add public-remote git@github.com:no-mood/nix-config.git"
  exit 1
fi

repo_root=$(git rev-parse --show-toplevel)
worktree_root=$(mktemp -d)
worktree="$worktree_root/public"

cleanup() {
  git -C "$repo_root" worktree remove --force "$worktree" &>/dev/null || true
  rm -rf "$worktree_root"
}
trap cleanup EXIT

if git -C "$repo_root" rev-parse --verify public &>/dev/null; then
  git -C "$repo_root" worktree add "$worktree" public
  git -C "$worktree" merge main --squash -X theirs
else
  git -C "$repo_root" worktree add --detach "$worktree" main
  git -C "$worktree" checkout --orphan public
  git -C "$worktree" read-tree -m -u main
fi

if ! git -C "$worktree" commit -m "sync with main" --no-verify 2>/dev/null; then
  echo "Nothing to commit — public is already up to date."
  exit 0
fi

git -C "$worktree" filter-repo \
  --path nixos/hosts/common/global/sensitive.nix \
  --path-glob '**/secrets.yaml' \
  --path-glob '**/ssh_host_*.pub' \
  --invert-paths \
  --force \
  --refs public

# The shared pre-push hook expects devenv's generated, ignored config in the worktree.
cp "$repo_root/.pre-commit-config.yaml" "$worktree/.pre-commit-config.yaml"

git -C "$worktree" push --force-with-lease public-remote public
git -C "$worktree" push --force-with-lease origin public
echo "public branch updated (sensitive.nix removed)."
