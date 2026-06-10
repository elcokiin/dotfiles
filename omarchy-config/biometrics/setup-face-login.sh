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
PROFILE="${HOWDY_PROFILE:-fast}"
USE_CNN="${HOWDY_USE_CNN:-}"
CERTAINTY="${HOWDY_CERTAINTY:-}"
TIMEOUT="${HOWDY_TIMEOUT:-}"
MAX_HEIGHT="${HOWDY_MAX_HEIGHT:-}"
DARK_THRESHOLD="${HOWDY_DARK_THRESHOLD:-}"
DEVICE_FPS="${HOWDY_DEVICE_FPS:-}"
FORCE_MJPEG="${HOWDY_FORCE_MJPEG:-}"
ROTATE="${HOWDY_ROTATE:-}"
ENROLL_COUNT="${HOWDY_ENROLL_COUNT:-3}"
RUN_HOWDY_TEST="${HOWDY_RUN_TEST:-0}"
ENROLL_PREVIEW="${HOWDY_ENROLL_PREVIEW:-prompt}"

usage() {
  cat <<'EOF'
Usage: setup-face-login.sh [--device <path>] [--profile fast|balanced|secure|cnn] [options]

Options:
  --device <path>   Camera path to use for Howdy (example: /dev/v4l/by-id/...)
                    You can also set HOWDY_DEVICE_PATH env var.
  --profile <name>  Tuning profile. Default: fast.
                    fast:     lower latency, more tolerant matches.
                    balanced: Howdy-like defaults.
                    secure:   stricter matching.
                    cnn:      more pose tolerant, slower without GPU.
  --use-cnn <bool>  Override CNN detector usage (true/false).
  --certainty <n>   Match threshold, 1-10. Higher is more tolerant; >5 is not recommended.
  --timeout <sec>   Seconds before password fallback.
  --max-height <px> Scale camera frames down to this height.
  --dark-threshold <n>
                    Darkness threshold for skipped frames.
  --device-fps <n>  Camera FPS. Some IR cameras behave better at 15.
  --force-mjpeg <bool>
                    Force MJPEG decoding for OpenCV.
  --rotate <0|1|2>  0 landscape, 1 try landscape/portrait, 2 portrait only.
  --enroll-count <n>
                    Number of Howdy face models to add. Default: 3.
  HOWDY_ENROLL_PREVIEW=prompt|always|never
                    Preview the selected camera before face enrollment captures.
                    Default: prompt.
  HOWDY_RUN_TEST=1  Run Howdy's graphical test window after setup.
                    Disabled by default because Qt/X11 often fails under sudo on Wayland.
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
    --profile)
      if [[ $# -lt 2 ]]; then
        print_error "ERROR: --profile requires a value"
        exit 1
      fi
      PROFILE="$2"
      shift 2
      ;;
    --use-cnn)
      if [[ $# -lt 2 ]]; then
        print_error "ERROR: --use-cnn requires true or false"
        exit 1
      fi
      USE_CNN="$2"
      shift 2
      ;;
    --certainty)
      if [[ $# -lt 2 ]]; then
        print_error "ERROR: --certainty requires a value"
        exit 1
      fi
      CERTAINTY="$2"
      shift 2
      ;;
    --timeout)
      if [[ $# -lt 2 ]]; then
        print_error "ERROR: --timeout requires a value"
        exit 1
      fi
      TIMEOUT="$2"
      shift 2
      ;;
    --max-height)
      if [[ $# -lt 2 ]]; then
        print_error "ERROR: --max-height requires a value"
        exit 1
      fi
      MAX_HEIGHT="$2"
      shift 2
      ;;
    --dark-threshold)
      if [[ $# -lt 2 ]]; then
        print_error "ERROR: --dark-threshold requires a value"
        exit 1
      fi
      DARK_THRESHOLD="$2"
      shift 2
      ;;
    --device-fps)
      if [[ $# -lt 2 ]]; then
        print_error "ERROR: --device-fps requires a value"
        exit 1
      fi
      DEVICE_FPS="$2"
      shift 2
      ;;
    --force-mjpeg)
      if [[ $# -lt 2 ]]; then
        print_error "ERROR: --force-mjpeg requires true or false"
        exit 1
      fi
      FORCE_MJPEG="$2"
      shift 2
      ;;
    --rotate)
      if [[ $# -lt 2 ]]; then
        print_error "ERROR: --rotate requires 0, 1, or 2"
        exit 1
      fi
      ROTATE="$2"
      shift 2
      ;;
    --enroll-count)
      if [[ $# -lt 2 ]]; then
        print_error "ERROR: --enroll-count requires a value"
        exit 1
      fi
      ENROLL_COUNT="$2"
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

case "$PROFILE" in
  fast)
    : "${USE_CNN:=false}"
    : "${CERTAINTY:=4.2}"
    : "${TIMEOUT:=3}"
    : "${MAX_HEIGHT:=320}"
    : "${DARK_THRESHOLD:=80}"
    : "${DEVICE_FPS:=15}"
    : "${FORCE_MJPEG:=true}"
    : "${ROTATE:=0}"
    ;;
  balanced)
    : "${USE_CNN:=false}"
    : "${CERTAINTY:=3.5}"
    : "${TIMEOUT:=4}"
    : "${MAX_HEIGHT:=320}"
    : "${DARK_THRESHOLD:=60}"
    : "${DEVICE_FPS:=-1}"
    : "${FORCE_MJPEG:=false}"
    : "${ROTATE:=0}"
    ;;
  secure)
    : "${USE_CNN:=false}"
    : "${CERTAINTY:=2.8}"
    : "${TIMEOUT:=5}"
    : "${MAX_HEIGHT:=360}"
    : "${DARK_THRESHOLD:=60}"
    : "${DEVICE_FPS:=-1}"
    : "${FORCE_MJPEG:=false}"
    : "${ROTATE:=0}"
    ;;
  cnn)
    : "${USE_CNN:=true}"
    : "${CERTAINTY:=3.5}"
    : "${TIMEOUT:=6}"
    : "${MAX_HEIGHT:=320}"
    : "${DARK_THRESHOLD:=80}"
    : "${DEVICE_FPS:=15}"
    : "${FORCE_MJPEG:=true}"
    : "${ROTATE:=0}"
    ;;
  *)
    print_error "ERROR: unknown profile: $PROFILE"
    usage
    exit 1
    ;;
esac

if ! [[ "$ENROLL_COUNT" =~ ^[1-9][0-9]*$ ]]; then
  print_error "ERROR: --enroll-count must be a positive integer"
  exit 1
fi

case "$ENROLL_PREVIEW" in
  1|true|yes)
    ENROLL_PREVIEW="always"
    ;;
  0|false|no)
    ENROLL_PREVIEW="never"
    ;;
  prompt|always|never)
    ;;
  *)
    print_error "ERROR: HOWDY_ENROLL_PREVIEW must be prompt, always, or never"
    exit 1
    ;;
esac

is_video_capture_device() {
  local dev="$1"
  v4l2-ctl --device="$dev" --info 2>/dev/null |
    awk '
      /Device Caps/ { in_device_caps = 1; next }
      /^Media Driver Info:/ { in_device_caps = 0 }
      in_device_caps && /Video Capture/ { found = 1 }
      END { exit found ? 0 : 1 }
    '
}

camera_name() {
  local dev="$1"
  v4l2-ctl --device="$dev" --info 2>/dev/null |
    awk -F: '/Card type/ { sub(/^[ \t]+/, "", $2); print $2; exit }'
}

stable_path_for_device() {
  local dev="$1"
  local resolved
  resolved="$(readlink -f "$dev")"

  local link
  for link in /dev/v4l/by-id/* /dev/v4l/by-path/*; do
    [[ -e "$link" ]] || continue
    [[ "$(readlink -f "$link")" == "$resolved" ]] || continue
    printf '%s\n' "$link"
    return
  done

  printf '%s\n' "$dev"
}

camera_score() {
  local path="$1"
  local name="$2"
  local text="${path,,} ${name,,}"
  local score=0

  [[ "$path" == /dev/v4l/by-id/* ]] && score=$((score + 20))
  [[ "$path" == /dev/v4l/by-path/* ]] && score=$((score + 10))
  [[ "$text" == *ir* ]] && score=$((score + 100))
  [[ "$text" == *infrared* ]] && score=$((score + 100))
  [[ "$text" == *hello* ]] && score=$((score + 80))
  [[ "$text" == *face* ]] && score=$((score + 20))
  [[ "$text" == *index0* ]] && score=$((score + 5))

  printf '%s\n' "$score"
}

preview_camera_device() {
  local path="$1"
  local dev
  dev="$(readlink -f "$path")"

  echo
  print_info "Opening camera preview: $path"
  print_info "Close the preview window to return to camera selection."

  if command -v mpv >/dev/null 2>&1; then
    mpv --profile=low-latency --untimed --force-window=immediate --title="Howdy camera preview: $path" "av://v4l2:$dev"
  elif command -v ffplay >/dev/null 2>&1; then
    ffplay -hide_banner -loglevel warning -f v4l2 -i "$dev"
  elif command -v qv4l2 >/dev/null 2>&1; then
    qv4l2 -d "$dev"
  else
    print_error "No camera preview app found."
    print_error "Install one of: mpv, ffmpeg/ffplay, or qv4l2."
    return 1
  fi
}

preview_before_enrollment() {
  local enrollment_number="$1"
  local choice

  case "$ENROLL_PREVIEW" in
    always)
      preview_camera_device "$DEVICE_PATH" || true
      return
      ;;
    never)
      return
      ;;
  esac

  while true; do
    read -r -p "Enrollment $enrollment_number: press p to preview camera, Enter to capture, s to skip previews: " choice
    case "$choice" in
      "")
        return
        ;;
      [Pp])
        preview_camera_device "$DEVICE_PATH" || true
        ;;
      [Ss])
        ENROLL_PREVIEW="never"
        return
        ;;
      *)
        print_error "ERROR: unknown choice: $choice"
        ;;
    esac
  done
}

read_enrollment_label() {
  local enrollment_number="$1"
  local default_label="Omarchy $PROFILE $enrollment_number"
  local label

  read -r -p "Label for enrollment $enrollment_number [$default_label]: " label
  label="${label:-$default_label}"
  MODEL_LABEL="${label:0:24}"
}

select_camera_device() {
  local devices=()
  local paths=()
  local names=()
  local scores=()
  local dev path name score best_index=0 best_score=-1

  for dev in /dev/video*; do
    [[ -e "$dev" ]] || continue
    is_video_capture_device "$dev" || continue

    path="$(stable_path_for_device "$dev")"
    name="$(camera_name "$dev")"
    score="$(camera_score "$path" "$name")"

    devices+=("$dev")
    paths+=("$path")
    names+=("$name")
    scores+=("$score")

    if (( score > best_score )); then
      best_score="$score"
      best_index="$((${#paths[@]} - 1))"
    fi
  done

  if (( ${#paths[@]} == 0 )); then
    print_error "ERROR: no video capture devices were detected."
    print_error "Check that your camera is enabled and visible under /dev/video*."
    exit 1
  fi

  echo
  print_info "==> Camera devices detected:"
  for i in "${!paths[@]}"; do
    local marker=""
    if (( i == best_index )); then
      marker=" (recommended)"
    fi
    printf '  %d) %s%s\n' "$((i + 1))" "${paths[$i]}" "$marker"
    printf '     %s [%s]\n' "${names[$i]:-Unknown camera}" "${devices[$i]}"
  done
  echo

  local choice preview_choice selected_index
  while true; do
    read -r -p "Select camera [$((best_index + 1))], preview with p or p<N>: " choice
    choice="${choice:-$((best_index + 1))}"

    if [[ "$choice" =~ ^[Pp]([[:space:]]*([0-9]+))?$ ]]; then
      preview_choice="${BASH_REMATCH[2]:-$((best_index + 1))}"
      if (( preview_choice < 1 || preview_choice > ${#paths[@]} )); then
        print_error "ERROR: invalid preview selection: $preview_choice"
        continue
      fi
      preview_camera_device "${paths[$((preview_choice - 1))]}" || true
      echo
      continue
    fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#paths[@]} )); then
      print_error "ERROR: invalid camera selection: $choice"
      continue
    fi

    selected_index="$((choice - 1))"
    DEVICE_PATH="${paths[$selected_index]}"
    break
  done
}

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

if [[ -n "$DEVICE_PATH" ]]; then
  print_info "Using provided camera path: $DEVICE_PATH"
else
  select_camera_device
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
print_info "==> Applying profile: $PROFILE"
sudo cp "$HOWDY_CONFIG" "${HOWDY_CONFIG}.bak.$(date +%F_%H%M%S)"

sudo python3 - "$HOWDY_CONFIG" "$DEVICE_PATH" "$USE_CNN" "$CERTAINTY" "$TIMEOUT" "$MAX_HEIGHT" "$DARK_THRESHOLD" "$DEVICE_FPS" "$FORCE_MJPEG" "$ROTATE" <<'PY'
import configparser, sys
(
    cfg_path,
    dev,
    use_cnn,
    certainty,
    timeout,
    max_height,
    dark_threshold,
    device_fps,
    force_mjpeg,
    rotate,
) = sys.argv[1:]
cfg = configparser.ConfigParser()
cfg.optionxform = str
cfg.read(cfg_path)

if not cfg.has_section("core"):
    cfg.add_section("core")
cfg.set("core", "use_cnn", use_cnn)
cfg.set("core", "abort_if_ssh", "true")
cfg.set("core", "abort_if_lid_closed", "true")

if not cfg.has_section("video"):
    cfg.add_section("video")
cfg.set("video", "device_path", dev)
cfg.set("video", "certainty", certainty)
cfg.set("video", "timeout", timeout)
cfg.set("video", "max_height", max_height)
cfg.set("video", "dark_threshold", dark_threshold)
cfg.set("video", "recording_plugin", "opencv")
cfg.set("video", "device_format", "v4l2")
cfg.set("video", "device_fps", device_fps)
cfg.set("video", "force_mjpeg", force_mjpeg)
cfg.set("video", "rotate", rotate)

if not cfg.has_section("snapshots"):
    cfg.add_section("snapshots")
cfg.set("snapshots", "save_failed", "false")
cfg.set("snapshots", "save_successful", "false")
cfg.set("snapshots", "capture_failed", "false")
cfg.set("snapshots", "capture_successful", "false")

with open(cfg_path, "w") as f:
    cfg.write(f)
print(
    "Configured Howdy: "
    f"device_path={dev}, use_cnn={use_cnn}, certainty={certainty}, "
    f"timeout={timeout}, max_height={max_height}, dark_threshold={dark_threshold}, "
    f"device_fps={device_fps}, force_mjpeg={force_mjpeg}, rotate={rotate}"
)
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
print_info "==> Enroll face models now (interactive)"
print_info "Add each model under a different normal condition: straight, slight left/right, glasses/no glasses, day/night."

for ((i = 1; i <= ENROLL_COUNT; i++)); do
  echo
  print_info "Enrollment $i of $ENROLL_COUNT"
  read_enrollment_label "$i"
  preview_before_enrollment "$i"
  if ! sudo howdy -y add "$MODEL_LABEL"; then
    print_error "\nFace enrollment failed."
    rollback
    exit 1
  fi
done

# -- 9) Test guidance ---------------------------------------------------------

echo
if [[ "$RUN_HOWDY_TEST" == "1" ]]; then
  print_info "==> Graphical Howdy test"
  if ! sudo howdy test; then
    print_info "Howdy's graphical test window failed to open."
    print_info "This usually means sudo/root could not access the desktop display, not that PAM face auth is broken."
  fi
else
  print_info "==> Skipping Howdy graphical test"
  print_info "Set HOWDY_RUN_TEST=1 if you explicitly want to try the Qt camera test window."
fi

echo
print_success "Done!"
echo "- Test sudo:        sudo -k && sudo -v"
echo "- Test lockscreen:  Super + Escape (Omarchy default)"
echo "- Test polkit:      GUI privilege prompts will try face auth first"
echo "- If face fails at sudo prompt, use Ctrl+C to fallback to password."
