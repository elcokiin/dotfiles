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
check_link "$SCRIPT_DIR/../herdr/config.toml" "$HOME/.config/herdr/config.toml"

THEME_LINK="$HOME/.config/nvim/lua/plugins/theme.lua"
THEME_TARGET="$HOME/.local/state/omarchy/current/theme/neovim.lua"
if [ -L "$THEME_LINK" ] && [ "$(readlink -f "$THEME_LINK")" = "$(readlink -f "$THEME_TARGET")" ]; then
  echo "✅ linked: $THEME_LINK -> omarchy current theme"
else
  echo "❌ missing or stale: $THEME_LINK"
fi

echo
echo "🔐 Biometrics status"
echo "--------------------"
if [ -f /etc/pam.d/hyprlock ] && grep -q '^auth sufficient pam_howdy.so$' /etc/pam.d/hyprlock; then
  echo "✅ /etc/pam.d/hyprlock has pam_howdy"
else
  echo "⚠️  /etc/pam.d/hyprlock missing pam_howdy"
fi

if [ -f /etc/pam.d/sudo ] && grep -q '^auth sufficient pam_howdy.so$' /etc/pam.d/sudo; then
  echo "✅ /etc/pam.d/sudo has pam_howdy"
else
  echo "⚠️  /etc/pam.d/sudo missing pam_howdy"
fi

if [ -f /etc/pam.d/polkit-1 ] && grep -q '^auth sufficient pam_howdy.so$' /etc/pam.d/polkit-1; then
  echo "✅ /etc/pam.d/polkit-1 has pam_howdy"
else
  echo "⚠️  /etc/pam.d/polkit-1 missing pam_howdy"
fi

echo
echo "Done."
