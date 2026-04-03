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
DEVICE_PATH="${HOWDY_DEVICE_PATH:-}"

usage() {
  cat <<'EOF'
Usage: setup-face-login.sh [--device <path>] [--help]

Options:
  --device <path>   Camera path to use for Howdy (example: /dev/v4l/by-id/...)
                    You can also set HOWDY_DEVICE_PATH env var.
  --help            Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device)
      if [[ $# -lt 2 ]]; then
        print_error "ERROR: --device requires a value"
        exit 1
      fi
      DEVICE_PATH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      print_error "ERROR: Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

# Track files we modify so we can rollback on failure
PAM_BACKUP_MAP=()   # pairs of "backup:original"

rollback() {
  print_error "\nRolling back changes..."
  for entry in "${PAM_BACKUP_MAP[@]}"; do
    local bak="${entry%%:*}"
    local orig="${entry##*:}"
    if [[ "$bak" == "__created__" ]]; then
      sudo rm -f "$orig"
      print_info "Removed created file: $orig"
    elif [[ -f "$bak" ]]; then
      sudo cp "$bak" "$orig"
      sudo rm -f "$bak"
      print_info "Restored: $orig"
    fi
  done
  # Revert hyprlock UI changes
  remove_hyprlock_face_icon
  print_error "Rollback complete. No face auth was configured."
}

# -- Hyprlock UI helpers (mirrors omarchy-setup-fingerprint pattern) ----------

add_hyprlock_face_icon() {
  if [[ ! -f "$HYPRLOCK_CONF" ]]; then
    print_info "WARN: $HYPRLOCK_CONF not found, skipping UI hints"
    return
  fi
  print_info "Adding face-login hint to hyprlock..."
  # Enable fingerprint/biometric field (used for all biometric auth in hyprlock)
  sed -i 's/fingerprint:enabled = .*/fingerprint:enabled = true/' "$HYPRLOCK_CONF"
  # Append a camera icon to the placeholder text if not already present
  if ! grep -q '󰭏' "$HYPRLOCK_CONF"; then
    sed -i 's/placeholder_text = .*/& 󰭏/' "$HYPRLOCK_CONF"
  fi
}

remove_hyprlock_face_icon() {
  if [[ ! -f "$HYPRLOCK_CONF" ]]; then
    return
  fi
  # Only disable fingerprint:enabled if fprintd is NOT also configured
  if ! grep -q 'pam_fprintd.so' /etc/pam.d/hyprlock 2>/dev/null; then
    sed -i 's/fingerprint:enabled = .*/fingerprint:enabled = false/' "$HYPRLOCK_CONF"
  fi
  # Remove the camera icon we added
  sed -i 's/ 󰭏//g' "$HYPRLOCK_CONF"
}

# -- PAM helpers --------------------------------------------------------------

add_pam_line_top() {
  local file="$1"
  local pam_line="$2"

  if [[ ! -f "$file" ]]; then
    print_info "WARN: $file not found, skipping"
    return
  fi
  if grep -Fqx "$pam_line" "$file"; then
    print_success "Already configured: $file"
    return
  fi

  local bak="${file}.bak.$(date +%F_%H%M%S)"
  sudo cp "$file" "$bak"
  PAM_BACKUP_MAP+=("${bak}:${file}")

  local tmp
  tmp="$(mktemp)"
  {
    echo "$pam_line"
    cat "$file"
  } >"$tmp"
  sudo install -m 644 "$tmp" "$file"
  rm -f "$tmp"
  print_success "Updated: $file"
}

add_polkit_pam() {
  local pam_line="$1"

  if [[ -f /etc/pam.d/polkit-1 ]]; then
    if grep -Fqx "$pam_line" /etc/pam.d/polkit-1; then
      print_success "Already configured: /etc/pam.d/polkit-1"
      return
    fi
    local bak="/etc/pam.d/polkit-1.bak.$(date +%F_%H%M%S)"
    sudo cp /etc/pam.d/polkit-1 "$bak"
    PAM_BACKUP_MAP+=("${bak}:/etc/pam.d/polkit-1")
    sudo sed -i "1i $pam_line" /etc/pam.d/polkit-1
    print_success "Updated: /etc/pam.d/polkit-1"
  else
    print_info "Creating /etc/pam.d/polkit-1 with face auth..."
    sudo tee /etc/pam.d/polkit-1 >/dev/null <<EOF
$pam_line
auth      required pam_unix.so

account   required pam_unix.so
password  required pam_unix.so
session   required pam_unix.so
EOF
    PAM_BACKUP_MAP+=("__created__:/etc/pam.d/polkit-1")
    print_success "Created: /etc/pam.d/polkit-1"
  fi
}

# =============================================================================
# Main
# =============================================================================

print_success "==> Omarchy/Arch facial auth setup (Howdy)\n"

# -- 1) Pick AUR helper ------------------------------------------------------

if command -v yay >/dev/null 2>&1; then
  AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
  AUR_HELPER="paru"
else
  print_error "ERROR: No AUR helper found (yay/paru). Install yay first."
  exit 1
fi

# -- 2) Install dependencies -------------------------------------------------

print_info "==> Installing dependencies..."
sudo pacman -S --needed --noconfirm v4l-utils
"$AUR_HELPER" -S --needed --noconfirm howdy-git

# -- 3) Camera selection + pre-validation -------------------------------------

echo
print_info "==> Camera devices detected:"
v4l2-ctl --list-devices || true
echo
print_info "Tip: prefer a stable path from /dev/v4l/by-id or /dev/v4l/by-path"
ls -l /dev/v4l/by-id  2>/dev/null || true
ls -l /dev/v4l/by-path 2>/dev/null || true
echo

if [[ -n "$DEVICE_PATH" ]]; then
  print_info "Using provided camera path: $DEVICE_PATH"
else
  read -r -p "Enter IR camera path (example: /dev/v4l/by-id/XXX or /dev/video2): " DEVICE_PATH
fi
if [[ ! -e "$DEVICE_PATH" ]]; then
  print_error "ERROR: device path does not exist: $DEVICE_PATH"
  exit 1
fi

# Pre-validate the camera responds before touching any system files
print_info "==> Validating camera device..."
if ! v4l2-ctl --device="$DEVICE_PATH" --all >/dev/null 2>&1; then
  print_error "ERROR: camera at $DEVICE_PATH did not respond."
  print_error "Check that the device is a working video capture device."
  exit 1
fi
print_success "Camera validated: $DEVICE_PATH"

# -- 4) Locate and configure Howdy --------------------------------------------

CONFIG_CANDIDATES=(
  "/lib/security/howdy/config.ini"
  "/usr/lib/security/howdy/config.ini"
  "/etc/howdy/config.ini"
)
HOWDY_CONFIG=""
for c in "${CONFIG_CANDIDATES[@]}"; do
  if [[ -f "$c" ]]; then
    HOWDY_CONFIG="$c"
    break
  fi
done

if [[ -z "$HOWDY_CONFIG" ]]; then
  print_error "ERROR: Could not find Howdy config.ini"
  exit 1
fi

print_info "==> Using config: $HOWDY_CONFIG"
sudo cp "$HOWDY_CONFIG" "${HOWDY_CONFIG}.bak.$(date +%F_%H%M%S)"

sudo python3 - "$HOWDY_CONFIG" "$DEVICE_PATH" <<'PY'
import configparser, sys
cfg_path, dev = sys.argv[1], sys.argv[2]
cfg = configparser.ConfigParser()
cfg.optionxform = str
cfg.read(cfg_path)

if not cfg.has_section("video"):
    cfg.add_section("video")
cfg.set("video", "device_path", dev)

if not cfg.has_section("snapshots"):
    cfg.add_section("snapshots")
cfg.set("snapshots", "capture_failed", "false")
cfg.set("snapshots", "capture_successful", "false")

with open(cfg_path, "w") as f:
    cfg.write(f)
print(f"Configured device_path={dev} and disabled snapshots in {cfg_path}")
PY

# -- 5) Decide PAM line based on installed module -----------------------------

if [[ -e /lib/security/pam_howdy.so || -e /usr/lib/security/pam_howdy.so ]]; then
  PAM_LINE="auth sufficient pam_howdy.so"
else
  PAM_LINE="auth sufficient pam_python.so /lib/security/howdy/pam.py"
fi
print_info "==> PAM line: $PAM_LINE"

# -- 6) Configure PAM for sudo, hyprlock, and polkit -------------------------

add_pam_line_top /etc/pam.d/sudo "$PAM_LINE"
add_pam_line_top /etc/pam.d/hyprlock "$PAM_LINE"
add_polkit_pam "$PAM_LINE"

# -- 7) Update hyprlock UI ---------------------------------------------------

add_hyprlock_face_icon

# -- 8) Enroll face (with rollback on failure) --------------------------------

echo
print_info "==> Enroll face now (interactive)"
print_info "Look at IR camera and follow prompts."

if ! sudo howdy add; then
  print_error "\nFace enrollment failed."
  rollback
  exit 1
fi

# -- 9) Quick test ------------------------------------------------------------

echo
print_info "==> Quick test"
sudo howdy test || true

echo
print_success "Done!"
echo "- Test sudo:        sudo -v"
echo "- Test lockscreen:  Super + Escape (Omarchy default)"
echo "- Test polkit:      GUI privilege prompts will try face auth first"
echo "- If face fails at sudo prompt, use Ctrl+C to fallback to password."
