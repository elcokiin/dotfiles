#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
WITH_BIOMETRICS=0

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [--with-biometrics] [--help]

What it does:
  1) Links Omarchy user configs (hypr + walker).
  2) Optionally configures face login (opt-in).

Options:
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

if [ "$WITH_BIOMETRICS" -eq 1 ]; then
  echo "🔐 Running biometric setup (opt-in enabled)..."
  if [ -n "${HOWDY_DEVICE_PATH:-}" ]; then
    "$SCRIPT_DIR/../biometrics/setup-face-login.sh" --device "$HOWDY_DEVICE_PATH"
  else
    "$SCRIPT_DIR/../biometrics/setup-face-login.sh"
  fi
else
  echo "⏭️  Skipping biometrics (opt-in)."
  echo "    To enable later: ./omarchy-config/bootstrap.sh --with-biometrics"
fi

echo "================================"
echo "✅ Bootstrap completed."
