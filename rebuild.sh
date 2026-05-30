#!/usr/bin/env bash
# Rebuild NixOS from this flake, then commit + push on success.
set -euo pipefail

cd "$HOME/nixos"

# Pull latest without clobbering local edits.
git pull --ff-only || true

# Format nix files if the formatter is present.
if command -v alejandra >/dev/null; then
  alejandra . >/dev/null || true
fi

# Show what changed.
git --no-pager diff -U0 || true

echo "Rebuilding (flake)…"
if ! sudo nixos-rebuild switch --flake "$HOME/nixos#nixos"; then
  echo "Rebuild failed." >&2
  exit 1
fi

# Commit + push (no-op if nothing changed).
if ! git diff --quiet || ! git diff --cached --quiet; then
  current="$(nixos-rebuild list-generations 2>/dev/null | grep -iE 'current' || true)"
  git commit -am "rebuild: ${current:-ok}"
  git push || true
else
  echo "No file changes to commit."
fi

echo "NixOS rebuild successful."
