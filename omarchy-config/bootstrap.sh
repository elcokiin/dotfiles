#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
WITH_BIOMETRICS=0
WITH_NVIM=0
WITH_TMUX=0

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [--with-nvim] [--with-tmux] [--with-biometrics] [--help]

What it does:
  1) Links Omarchy user configs (hypr + walker + fcitx5).
  2) Optionally links Neovim, tmux, and face login.

Options:
  --with-nvim         Link the Omarchy LazyVim config into ~/.config/nvim.
  --with-tmux         Link the Omarchy tmux config into ~/.config/tmux.
  --with-biometrics   Run biometric setup (Howdy + PAM + enrollment).
                      Requires sudo and interactive enrollment.
  --help              Show this help.

Environment:
  HOWDY_DEVICE_PATH   Optional camera path passed to setup-face-login.sh.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --with-biometrics)
      WITH_BIOMETRICS=1
      shift
      ;;
    --with-nvim)
      WITH_NVIM=1
      shift
      ;;
    --with-tmux)
      WITH_TMUX=1
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

echo "🚀 Starting Omarchy bootstrap..."
echo "================================"

echo "🔗 Linking Hypr config..."
"$SCRIPT_DIR/install-hypr.sh" "$SCRIPT_DIR"

echo "🔗 Linking Walker config..."
"$SCRIPT_DIR/install-walker.sh" "$SCRIPT_DIR"

echo "🔗 Linking Fcitx5 config..."
"$SCRIPT_DIR/install-fcitx5.sh" "$SCRIPT_DIR"

echo "🔗 Linking Omarchy hooks..."
"$SCRIPT_DIR/install-hooks.sh" "$SCRIPT_DIR"

if [ "$WITH_NVIM" -eq 1 ]; then
  echo "🔗 Linking Neovim config..."
  "$SCRIPT_DIR/install-nvim.sh" "$SCRIPT_DIR"
else
  echo "⏭️  Skipping Neovim (opt-in)."
  echo "    To enable later: ./omarchy-config/bootstrap.sh --with-nvim"
fi

if [ "$WITH_TMUX" -eq 1 ]; then
  echo "🔗 Linking tmux config..."
  "$SCRIPT_DIR/install-tmux.sh" "$SCRIPT_DIR"
else
  echo "⏭️  Skipping tmux (opt-in)."
  echo "    To enable later: ./omarchy-config/bootstrap.sh --with-tmux"
fi

if [ "$WITH_BIOMETRICS" -eq 1 ]; then
  echo "🔐 Running biometric setup (opt-in enabled)..."
  if [ -n "${HOWDY_DEVICE_PATH:-}" ]; then
    "$SCRIPT_DIR/biometrics/setup-face-login.sh" --device "$HOWDY_DEVICE_PATH"
  else
    "$SCRIPT_DIR/biometrics/setup-face-login.sh"
  fi
else
  echo "⏭️  Skipping biometrics (opt-in)."
  echo "    To enable later: ./omarchy-config/bootstrap.sh --with-biometrics"
fi

echo "================================"
echo "✅ Bootstrap completed."
