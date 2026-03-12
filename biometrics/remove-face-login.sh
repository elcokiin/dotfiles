#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}$1${NC}"; }
print_error()   { echo -e "${RED}$1${NC}"; }
print_info()    { echo -e "${YELLOW}$1${NC}"; }

HYPRLOCK_CONF="$HOME/.config/hypr/hyprlock.conf"

print_info "==> Removing facial auth integration (Howdy)\n"

# -- PAM cleanup --------------------------------------------------------------

PAM_LINES=(
  "auth sufficient pam_howdy.so"
  "auth sufficient pam_python.so /lib/security/howdy/pam.py"
)

remove_pam_lines() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    print_info "WARN: $file not found, skipping"
    return
  fi

  local changed=0
  for line in "${PAM_LINES[@]}"; do
    if grep -Fqx "$line" "$file"; then
      changed=1
      break
    fi
  done

  if [[ "$changed" -eq 0 ]]; then
    print_info "No Howdy PAM lines in: $file"
    return
  fi

  sudo cp "$file" "${file}.bak.$(date +%F_%H%M%S)"

  local tmp
  tmp="$(mktemp)"
  cp "$file" "$tmp"

  for line in "${PAM_LINES[@]}"; do
    sed -i "\\|^${line//\//\\/}$|d" "$tmp"
  done

  sudo install -m 644 "$tmp" "$file"
  rm -f "$tmp"
  print_success "Updated: $file"
}

remove_pam_lines /etc/pam.d/sudo
remove_pam_lines /etc/pam.d/hyprlock
remove_pam_lines /etc/pam.d/polkit-1

# -- Hyprlock UI cleanup ------------------------------------------------------

if [[ -f "$HYPRLOCK_CONF" ]]; then
  print_info "Removing face-login hint from hyprlock..."
  # Only disable fingerprint:enabled if fprintd is NOT also configured
  if ! grep -q 'pam_fprintd.so' /etc/pam.d/hyprlock 2>/dev/null; then
    sed -i 's/fingerprint:enabled = .*/fingerprint:enabled = false/' "$HYPRLOCK_CONF"
  fi
  # Remove the camera icon
  sed -i 's/ 󰭏//g' "$HYPRLOCK_CONF"
  print_success "Restored hyprlock UI"
else
  print_info "WARN: $HYPRLOCK_CONF not found, skipping UI cleanup"
fi

# -- Done ---------------------------------------------------------------------

echo
print_info "==> Optional cleanup"
echo "You can also remove enrolled faces and the package if you want:"
echo "- Remove faces:      sudo howdy clear"
echo "- Uninstall package: yay -Rns howdy-git  (or paru -Rns howdy-git)"
echo
print_success "Done."
