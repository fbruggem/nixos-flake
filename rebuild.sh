#!/usr/bin/env bash
# Rebuild NixOS from this flake, then commit + push on success.
#
# Host attribute defaults to this machine's hostname; pass one to override:
#   ./rebuild.sh                 # builds nixosConfigurations.$HOSTNAME
#   ./rebuild.sh other-host      # builds nixosConfigurations.other-host
set -euo pipefail

cd "$HOME/nixos"

# Flake host: first arg if given, otherwise this machine's hostname.
host="${1:-$HOSTNAME}"

# Pull latest without clobbering local edits.
git pull --ff-only || true

# Format nix files if the formatter is present.
if command -v alejandra >/dev/null; then
  alejandra . >/dev/null || true
fi

# Show what changed.
git --no-pager diff -U0 || true

echo "Rebuilding (flake) → ${host}…"
if ! sudo nixos-rebuild switch --flake "$HOME/nixos#$host"; then
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
