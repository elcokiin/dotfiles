#!/bin/sh

# Install keyd system-wide: links this repo's default.conf into /etc/keyd
# and enables the keyd daemon.
#
# Run it directly and it auto-elevates with sudo when needed:
#   .config/keyd/install.sh
# (or explicitly: sudo .config/keyd/install.sh)

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
CONF_SOURCE="$SCRIPT_DIR/default.conf"
CONF_TARGET="/etc/keyd/default.conf"

if ! command -v keyd >/dev/null 2>&1; then
  echo "❌ Error: keyd is not installed. Install it first (omarchy-pkg-add keyd)."
  exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
  echo "🔑 Elevating with sudo (needed to write /etc/keyd and start the daemon)..."
  exec sudo "$0" "$@"
fi

mkdir -p /etc/keyd

if [ -L "$CONF_TARGET" ] && [ "$(readlink -f "$CONF_TARGET")" = "$(readlink -f "$CONF_SOURCE")" ]; then
  echo "✔️  $CONF_TARGET is already linked correctly."
else
  if [ -e "$CONF_TARGET" ] || [ -L "$CONF_TARGET" ]; then
    backup="${CONF_TARGET}.back.$(date +%s)"
    echo "📦 Backing up existing $(basename "$CONF_TARGET") to $backup"
    mv "$CONF_TARGET" "$backup"
  fi
  echo "🔗 Linking $CONF_TARGET -> $CONF_SOURCE"
  ln -s "$CONF_SOURCE" "$CONF_TARGET"
fi

systemctl enable --now keyd
echo "✅ keyd is $(systemctl is-active keyd)."

cat <<'EOF'

Next steps:
  sudo keyd monitor   # see what keyd receives while typing
  sudo keyd check     # inspect the parsed config
  sudo keyd reload    # when u modify the default.conf reload the config with this
EOF

# When launched from a terminal (e.g. via link.sh), keep the window open so
# the result stays readable. No-op when stdin is not a TTY.
if [ -t 0 ]; then
  echo
  printf 'Press Enter to close this window... '
  read -r _
fi
