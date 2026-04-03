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

check_link "$HYPR_DOTFILES/bindings.conf" "$HOME/.config/hypr/bindings.conf"
check_link "$HYPR_DOTFILES/hypridle.conf" "$HOME/.config/hypr/hypridle.conf"
check_link "$HYPR_DOTFILES/input.conf" "$HOME/.config/hypr/input.conf"
check_link "$HYPR_DOTFILES/monitors.conf" "$HOME/.config/hypr/monitors.conf"

if [ -f "$HYPR_DOTFILES/hyprlock.conf" ]; then
  check_link "$HYPR_DOTFILES/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
else
  echo "⚠️  dotfiles hyprlock.conf not found: $HYPR_DOTFILES/hyprlock.conf"
fi

if [ -L "$HOME/.config/walker" ] && [ "$(readlink -f "$HOME/.config/walker")" = "$(readlink -f "$SCRIPT_DIR/walker")" ]; then
  echo "✅ linked: $HOME/.config/walker -> $SCRIPT_DIR/walker"
elif [ -e "$HOME/.config/walker" ] || [ -L "$HOME/.config/walker" ]; then
  echo "⚠️  exists but not linked as expected: $HOME/.config/walker"
else
  echo "❌ missing: $HOME/.config/walker"
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

if [ -f "$HOME/.config/hypr/hyprlock.conf" ] && grep -q 'fingerprint:enabled = true' "$HOME/.config/hypr/hyprlock.conf"; then
  echo "✅ hyprlock biometric UI enabled"
else
  echo "⚠️  hyprlock biometric UI not enabled"
fi

echo
echo "Done."
