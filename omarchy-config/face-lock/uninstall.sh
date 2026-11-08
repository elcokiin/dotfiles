#!/usr/bin/env bash
# Remove the Quickshell lock-screen face integration.

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

say()  { echo -e "${GREEN}$*${NC}"; }
warn() { echo -e "${YELLOW}$*${NC}"; }
die()  { echo -e "${RED}$*${NC}" >&2; exit 1; }

PLUGIN_ID="${USER}.lock"
PLUGIN_DIR="$HOME/.config/omarchy/plugins/$PLUGIN_ID"
PAM_DST="/etc/pam.d/omarchy-lock-face"

((EUID != 0)) || die "Run this as your normal user; it calls sudo itself."

say "==> Removing the lock-screen face PAM service"
if [[ -f "$PAM_DST" ]]; then
  latest_backup="$(find /etc/pam.d -maxdepth 1 -name 'omarchy-lock-face.back.*' -printf '%T@ %p\n' 2>/dev/null |
    sort -nr | head -n1 | cut -d' ' -f2-)"
  if [[ -n "${latest_backup:-}" && -f "$latest_backup" ]]; then
    sudo cp -a "$latest_backup" "$PAM_DST"
    say "Restored $latest_backup"
  else
    sudo rm -f "$PAM_DST"
    say "Removed $PAM_DST"
  fi
fi

if omarchy plugin list --json 2>/dev/null | jq -e --arg id "$PLUGIN_ID" 'any(.[]; .id == $id)' >/dev/null; then
  say "==> Removing the cloned lock plugin"
  omarchy plugin remove "$PLUGIN_ID" --yes
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
fi

# The clone normally restores the built-in on removal; make it explicit in
# case the plugin registry did not get the change.
omarchy plugin enable omarchy.lock >/dev/null 2>&1 || true
omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true

if omarchy-shell lock status >/dev/null 2>&1; then
  say "==> Built-in lock is back:"
  omarchy-shell lock status | jq .
else
  warn "The shell did not answer 'lock status'. Log out and back in, then check:"
  warn "  omarchy-shell lock status"
fi

say ""
say "Facelock tuning in /etc/facelock/config.toml is left in place."
say "To revert it, restore the newest /etc/facelock/config.toml.back.* file."
