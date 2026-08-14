#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
WITH_TMUX=0
WITH_BIOMETRICS=0

usage() {
  cat <<'EOF'
Usage: link.sh [--with-tmux] [--with-biometrics] [--help]

Single global symlink setup for Omarchy dotfiles. Links every customized
config into its place under ~/.config (and ~/.local/share where needed).

Linked by default:
  - hypr/*        -> ~/.config/hypr
  - fcitx5/*      -> ~/.config/fcitx5  (+ conf/*, themes -> ~/.local/share/fcitx5/themes)
  - hooks/*       -> ~/.config/omarchy/hooks
  - herdr/config.toml -> ~/.config/herdr
  - nvim/         -> ~/.config/nvim (via stow)

Options:
  --with-tmux         Also link tmux-before-native -> ~/.config/tmux.
  --with-biometrics   Run biometric setup (Howdy + PAM + enrollment).
                      Requires sudo and interactive enrollment.
  --help              Show this help.

Environment:
  HOWDY_DEVICE_PATH   Optional camera path passed to setup-face-login.sh.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --with-tmux)
      WITH_TMUX=1
      shift
      ;;
    --with-biometrics)
      WITH_BIOMETRICS=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "❌ Error: Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

# nvim is linked by default, so stow is always required.
if ! command -v stow >/dev/null 2>&1; then
  echo "❌ Error: 'stow' is not installed. Please install it first."
  exit 1
fi

echo "🔗 Linking Omarchy configs..."
echo "============================="

# --- Shared helper -----------------------------------------------------------
# If the target is already a symlink to the source, skip. Anything else is
# backed up (appended .back.<timestamp>) and replaced with a symlink.
link() {
  source_path="$1"
  target_path="$2"

  [ -e "$source_path" ] || return 0

  if [ -L "$target_path" ] && [ "$(readlink -f "$target_path")" = "$(readlink -f "$source_path")" ]; then
    echo "✔️  $(basename "$target_path") is already linked correctly."
    return
  fi

  mkdir -p "$(dirname "$target_path")"

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    backup="${target_path}.back.$(date +%s)"
    echo "📦 Backing up existing $(basename "$target_path") to $backup"
    mv "$target_path" "$backup"
  fi

  echo "🔗 Linking $target_path -> $source_path"
  ln -s "$source_path" "$target_path"
}

# --- Hypr --------------------------------------------------------------------
echo
echo "● Hypr"
for src_file in "$SCRIPT_DIR"/hypr/*; do
  [ -f "$src_file" ] || continue
  case "$src_file" in
    *.back) continue ;;
  esac
  link "$src_file" "$HOME/.config/hypr/$(basename "$src_file")"
done

# --- Fcitx5 ------------------------------------------------------------------
echo
echo "● Fcitx5"
for src_file in "$SCRIPT_DIR"/fcitx5/*; do
  [ -f "$src_file" ] || continue
  link "$src_file" "$HOME/.config/fcitx5/$(basename "$src_file")"
done

for src_conf in "$SCRIPT_DIR"/fcitx5/conf/*; do
  [ -f "$src_conf" ] || continue
  link "$src_conf" "$HOME/.config/fcitx5/conf/$(basename "$src_conf")"
done

for src_theme in "$SCRIPT_DIR"/fcitx5/themes/*; do
  [ -d "$src_theme" ] || continue
  link "$src_theme" "$HOME/.local/share/fcitx5/themes/$(basename "$src_theme")"
done

# --- Omarchy hooks -----------------------------------------------------------
echo
echo "● Omarchy hooks"
for src_file in "$SCRIPT_DIR"/hooks/*; do
  [ -f "$src_file" ] || continue
  link "$src_file" "$HOME/.config/omarchy/hooks/$(basename "$src_file")"
done

# --- Herdr -------------------------------------------------------------------
echo
echo "● Herdr"
link "$SCRIPT_DIR/../herdr/config.toml" "$HOME/.config/herdr/config.toml"

# --- Neovim (default, via stow) ----------------------------------------------
echo
echo "● Neovim"
TARGET_NVIM="$HOME/.config/nvim"
BACKUP_NVIM="$HOME/.config/nvim_backup_$(date +%s)"

if [ -e "$TARGET_NVIM" ] || [ -L "$TARGET_NVIM" ]; then
  echo "📦 Backing up existing nvim config to $BACKUP_NVIM"
  mv "$TARGET_NVIM" "$BACKUP_NVIM"
fi
mkdir -p "$TARGET_NVIM"
(
  cd "$SCRIPT_DIR"
  stow -t "$TARGET_NVIM" nvim
)
echo "✔️  nvim config stowed."

# --- Tmux (opt-in) -----------------------------------------------------------
if [ "$WITH_TMUX" -eq 1 ]; then
  echo
  echo "● Tmux"
  link "$SCRIPT_DIR/tmux-before-native/tmux.conf" "$HOME/.config/tmux/tmux.conf"
  link "$SCRIPT_DIR/tmux-before-native/omarchy-current-theme.conf" "$HOME/.config/tmux/omarchy-current-theme.conf"
else
  echo "⏭️  Skipping Tmux (opt-in). Use --with-tmux."
fi

# --- Biometrics (opt-in) -----------------------------------------------------
if [ "$WITH_BIOMETRICS" -eq 1 ]; then
  echo
  echo "🔐 Running biometric setup (opt-in enabled)..."
  if [ -n "${HOWDY_DEVICE_PATH:-}" ]; then
    "$SCRIPT_DIR/biometrics/setup-face-login.sh" --device "$HOWDY_DEVICE_PATH"
  else
    "$SCRIPT_DIR/biometrics/setup-face-login.sh"
  fi
else
  echo
  echo "⏭️  Skipping biometrics (opt-in). Use --with-biometrics."
fi

echo
echo "============================="
echo "✅ Links complete. Run ./omarchy-config/doctor.sh to verify."