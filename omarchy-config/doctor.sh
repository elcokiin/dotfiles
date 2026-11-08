#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
HYPR_DOTFILES="$SCRIPT_DIR/hypr"

check_link() {
  source_path="$1"
  target_path="$2"

  if [ -L "$target_path" ] && [ "$(readlink -f "$target_path")" = "$(readlink -f "$source_path")" ]; then
    echo "✅ linked: $target_path -> $source_path"
  elif [ -e "$target_path" ] || [ -L "$target_path" ]; then
    echo "⚠️  exists but not linked as expected: $target_path"
  else
    echo "❌ missing: $target_path"
  fi
}

echo "🩺 Omarchy dotfiles doctor"
echo "=========================="

check_link "$HYPR_DOTFILES/bindings.lua" "$HOME/.config/hypr/bindings.lua"
check_link "$HYPR_DOTFILES/input.lua" "$HOME/.config/hypr/input.lua"
check_link "$HYPR_DOTFILES/monitors.lua" "$HOME/.config/hypr/monitors.lua"
check_link "$HYPR_DOTFILES/autostart.lua" "$HOME/.config/hypr/autostart.lua"
check_link "$SCRIPT_DIR/omarchy/shell.json" "$HOME/.config/omarchy/shell.json"
check_link "$SCRIPT_DIR/omarchy/extensions/omarchy-menu.jsonc" "$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
check_link "$SCRIPT_DIR/../.config/systemd/user/omarchy-proxy-gost.service" "$HOME/.config/systemd/user/omarchy-proxy-gost.service"
check_link "$SCRIPT_DIR/proxy/omarchy-proxy" "$HOME/.config/omarchy/proxy/omarchy-proxy"
check_link "$SCRIPT_DIR/proxy/shell.sh" "$HOME/.config/omarchy/proxy/shell.sh"
check_link "$SCRIPT_DIR/proxy/omarchy-proxy" "$HOME/.local/bin/omarchy-proxy"
check_link "$SCRIPT_DIR/../.config/herdr/config.toml" "$HOME/.config/herdr/config.toml"
check_link "$SCRIPT_DIR/../.config/keyd/default.conf" "/etc/keyd/default.conf"
check_link "$SCRIPT_DIR/../.agents" "$HOME/.agents"

THEME_LINK="$HOME/.config/nvim/lua/plugins/theme.lua"
THEME_TARGET="$HOME/.local/state/omarchy/current/theme/neovim.lua"
if [ -L "$THEME_LINK" ] && [ "$(readlink -f "$THEME_LINK")" = "$(readlink -f "$THEME_TARGET")" ]; then
  echo "✅ linked: $THEME_LINK -> omarchy current theme"
else
  echo "❌ missing or stale: $THEME_LINK"
fi

if grep -qF '.config/omarchy/proxy/shell.sh' "$HOME/.bashrc" 2>/dev/null; then
  echo "✅ ~/.bashrc loads the proxy helpers"
else
  echo "⚠️  ~/.bashrc does not load the proxy helpers"
fi

if command -v omarchy-proxy >/dev/null 2>&1; then
  if omarchy-proxy active >/dev/null 2>&1; then
    echo "✅ proxy: ACTIVO"
  else
    echo "ℹ️  proxy: desactivado"
  fi
else
  echo "❌ omarchy-proxy is not on PATH"
fi

echo
echo "🔐 Biometrics status (Facelock)"
echo "-------------------------------"

if command -v facelock >/dev/null 2>&1; then
  echo "✅ facelock is installed"
else
  echo "❌ facelock is not installed"
fi

if facelock status 2>/dev/null | grep -q '\[ok\] responding'; then
  echo "✅ facelock daemon is responding"
else
  echo "⚠️  facelock daemon is not responding"
fi

if facelock list --user "$USER" 2>/dev/null | grep -qE 'Total: [1-9][0-9]* model'; then
  echo "✅ $USER has enrolled face models"
else
  echo "⚠️  $USER has no enrolled face models (facelock enroll)"
fi

if facelock status 2>/dev/null | grep -q 'require_ir: yes'; then
  echo "✅ facelock requires an IR camera"
else
  echo "⚠️  facelock does not require an IR camera"
fi

for pam_service in sudo polkit-1; do
  if [ -f "/etc/pam.d/$pam_service" ] && grep -qE '^auth[[:space:]]+sufficient[[:space:]]+pam_facelock\.so' "/etc/pam.d/$pam_service"; then
    echo "✅ /etc/pam.d/$pam_service has pam_facelock"
  else
    echo "⚠️  /etc/pam.d/$pam_service missing pam_facelock"
  fi
done

if [ -f /etc/pam.d/omarchy-lock-face ] && grep -qE '^auth[[:space:]]+sufficient[[:space:]]+pam_facelock\.so' /etc/pam.d/omarchy-lock-face; then
  echo "✅ /etc/pam.d/omarchy-lock-face has pam_facelock"
else
  echo "⚠️  /etc/pam.d/omarchy-lock-face missing; the lock screen will use password only"
fi

if [ -d "$HOME/.config/omarchy/plugins/$USER.lock" ]; then
  echo "✅ patched lock plugin is installed ($USER.lock)"
  base_version="$(cat "$SCRIPT_DIR/face-lock/plugin/base-version" 2>/dev/null || true)"
  installed_version="$(pacman -Q omarchy 2>/dev/null | awk '{print $2}' || true)"
  if [ -n "$base_version" ] && [ "$base_version" != "$installed_version" ]; then
    echo "ℹ️  lock plugin targets Omarchy $base_version, $installed_version is installed; re-clone after major lock changes"
  fi
else
  echo "ℹ️  patched lock plugin is not installed (built-in lock in use)"
fi

lock_status="$(omarchy-shell lock status 2>/dev/null || true)"
if printf '%s' "$lock_status" | grep -q '"passwordPam":true'; then
  echo "✅ Quickshell lock reports a working password lane"
else
  echo "❌ Quickshell lock did not answer lock status"
fi
if printf '%s' "$lock_status" | grep -q '"face":true'; then
  echo "✅ Quickshell lock sees the face lane"
elif printf '%s' "$lock_status" | grep -q '"face"'; then
  echo "⚠️  Quickshell lock is patched but does not see the face lane"
fi

echo
echo "Done."
