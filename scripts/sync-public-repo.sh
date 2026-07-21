#!/usr/bin/env bash
# Sync the public branch: single commit from main, strip sensitive.nix, push.
set -euo pipefail

if ! git remote get-url public-remote &>/dev/null; then
  echo "ERROR: remote 'public-remote' not found. Add it with:"
  echo "  git remote add public-remote git@github.com:no-mood/nix-config.git"
  exit 1
fi

if git rev-parse --verify public &>/dev/null; then
  git checkout public
  git merge main --squash -X theirs
else
  git checkout --orphan public
  git read-tree -m -u main
fi
if ! git commit -m "sync with main" --no-verify 2>/dev/null; then
  echo "Nothing to commit — public is already up to date."
  git checkout main
  exit 0
fi

git filter-repo \
  --path nixos/hosts/common/global/sensitive.nix \
  --path-glob '**/secrets.yaml' \
  --path-glob '**/ssh_host_*.pub' \
  --invert-paths \
  --force \
  --refs public

git push --force-with-lease public-remote public
git push --force-with-lease origin public
git checkout main
echo "public branch updated (sensitive.nix removed)."
