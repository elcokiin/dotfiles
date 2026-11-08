#!/usr/bin/env bash
# Connect Facelock to the Omarchy Quickshell lock screen.
#
# Run as your normal user (not root):  ./omarchy-config/face-lock/install.sh
# It asks for sudo only for the system pieces.

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

say()  { echo -e "${GREEN}$*${NC}"; }
warn() { echo -e "${YELLOW}$*${NC}"; }
die()  { echo -e "${RED}$*${NC}" >&2; exit 1; }

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PLUGIN_SRC="$SCRIPT_DIR/plugin"
PLUGIN_ID="${USER}.lock"
PLUGIN_DIR="$HOME/.config/omarchy/plugins/$PLUGIN_ID"
PAM_SRC="$SCRIPT_DIR/pam/omarchy-lock-face"
PAM_DST="/etc/pam.d/omarchy-lock-face"
CONFIG="/etc/facelock/config.toml"
BASE_VERSION="$(cat "$SCRIPT_DIR/plugin/base-version")"

FORCE=0
RECLONE=0

usage() {
  cat <<'EOF'
Usage: install.sh [--reclone] [--force] [--help]

  --reclone  Re-clone the built-in lock plugin before applying the face patch.
             Use after an Omarchy update that changed the lock.
  --force    Install even when the running Omarchy version differs from the
             version this copy of the plugin was written against.
EOF
}

while (($#)); do
  case "$1" in
    --reclone) RECLONE=1 ;;
    --force) FORCE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

((EUID != 0)) || die "Run this as your normal user; it calls sudo itself."
command -v facelock >/dev/null || die "facelock is not installed."
command -v omarchy >/dev/null || die "omarchy is not on PATH."
command -v jq >/dev/null || die "jq is required."
command -v python3 >/dev/null || die "python3 is required."

[[ -f /etc/pam.d/omarchy-lock-password ]] ||
  die "/etc/pam.d/omarchy-lock-password is missing; the Quickshell lock is not configured."

if ! facelock list --user "$USER" 2>/dev/null | grep -qE 'Total: [1-9][0-9]* model'; then
  die "No face models enrolled for $USER. Run: facelock enroll"
fi

if ! facelock status 2>/dev/null | grep -q 'require_ir: yes'; then
  warn "Facelock is not requiring an IR camera. Face unlock on an RGB camera can be fooled by a photo."
  warn "Turn it back on in $CONFIG ([security] require_ir = true) unless you are testing."
fi

CURRENT_VERSION="$(pacman -Q omarchy 2>/dev/null | awk '{print $2}')"
if [[ "$CURRENT_VERSION" != "$BASE_VERSION" ]] && ((!FORCE)); then
  die "This plugin copy targets Omarchy $BASE_VERSION, but $CURRENT_VERSION is installed.
Re-clone and port the patch, or rerun with --force to try anyway:
  omarchy plugin remove $PLUGIN_ID --yes
  omarchy plugin clone omarchy.lock"
fi

say "==> Installing the lock-screen face PAM service"
if [[ -f "$PAM_DST" ]]; then
  sudo cp -a "$PAM_DST" "$PAM_DST.back.$(date +%Y%m%d-%H%M%S)"
fi
sudo install -Dm644 -o root -g root "$PAM_SRC" "$PAM_DST"

say "==> Tuning Facelock for lock-screen latency"
sudo python3 "$SCRIPT_DIR/tune-facelock.py" "$CONFIG"

say "==> Restarting the Facelock daemon"
sudo systemctl restart facelock-daemon

say "==> Installing the patched Quickshell lock plugin"
if ((RECLONE)); then
  omarchy plugin remove "$PLUGIN_ID" --yes >/dev/null 2>&1 || true
fi
# Two clones of the same service would both try to take the session lock.
shopt -s nullglob
for other in "$HOME/.config/omarchy/plugins"/*.lock; do
  [[ "$other" == "$PLUGIN_DIR" ]] && continue
  if jq -e '.omarchy.clonedFrom == "omarchy.lock"' "$other/manifest.json" >/dev/null 2>&1; then
    die "Another clone of omarchy.lock already exists: $other
Remove it first: omarchy plugin remove $(basename "$other") --yes"
  fi
done
shopt -u nullglob

if [[ ! -d "$PLUGIN_DIR" ]]; then
  omarchy plugin clone omarchy.lock
fi

stamp="$(date +%Y%m%d-%H%M%S)"
for file in Service.qml LockView.qml; do
  [[ -f "$PLUGIN_DIR/$file" ]] && cp -a "$PLUGIN_DIR/$file" "$PLUGIN_DIR/$file.back.$stamp"
done

# LockView first: the old Service does not pass the new properties, so the
# reload that this copy triggers stays valid. The reverse order would assign
# faceConfigured on a LockView that has no such property.
cp -a "$PLUGIN_SRC/LockView.qml" "$PLUGIN_DIR/LockView.qml"
cp -a "$PLUGIN_SRC/Service.qml" "$PLUGIN_DIR/Service.qml"

omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true

status=""
for _ in $(seq 1 40); do
  status="$(omarchy-shell lock status 2>/dev/null || true)"
  if jq -e '.passwordPam == true and .face == true' <<<"$status" >/dev/null 2>&1; then
    break
  fi
  sleep 0.25
done

if ! jq -e '.passwordPam == true and .face == true' <<<"$status" >/dev/null 2>&1; then
  warn "The patched lock did not report a working face lane:"
  echo "$status"
  warn "Rolling back to the built-in lock..."
  omarchy plugin remove "$PLUGIN_ID" --yes >/dev/null 2>&1 || true
  omarchy plugin enable omarchy.lock >/dev/null 2>&1 || true
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
  die "Rolled back. The face PAM service stays in $PAM_DST; remove it with uninstall.sh."
fi

say ""
say "Done. Lock screen status:"
jq . <<<"$status"
say ""
say "Test it now:"
say "  1. Press Super + Escape to lock."
say "  2. Look at the camera and press any key (or click)."
say "  3. If the face misses, type your password as usual."
say ""
say "Watch the attempts with:"
say "  omarchy-shell lock status | jq '{face,authenticating,lastEvent,lastEventAt}'"
say ""
say "Undo everything with: omarchy-config/face-lock/uninstall.sh"
