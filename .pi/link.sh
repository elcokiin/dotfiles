#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PI_AGENT_DIR="${HOME}/.pi/agent"

usage() {
  cat <<'EOF'
Usage: link.sh [--help]

Deploy the global pi config from this dotfiles folder into ~/.pi/agent.

Stows via GNU stow: agent/themes/, agent/extensions/.

agent/settings.json is NOT synced — pi owns it at runtime and it is left
machine-local (gitignored). Skills are global (synced from ~/.agents/skills)
and auto-discovered by pi. Never touches secrets or runtime state:
settings.json, auth.json, models-store.json, sessions/, skills/, git/,
trust.json and ~/.pi/*.json/log stay on the machine.
EOF
}

for arg in "$@"; do
  case "$arg" in
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "❌ Error: Unknown argument: $arg"
      usage
      exit 1
      ;;
  esac
done

if [ ! -d "$SCRIPT_DIR/agent" ]; then
  echo "❌ Error: package '$SCRIPT_DIR/agent' does not exist."
  exit 1
fi

if ! command -v stow >/dev/null 2>&1; then
  echo "❌ Error: 'stow' is not installed. Please install it first."
  exit 1
fi

echo "🔗 Linking pi config -> $PI_AGENT_DIR"
echo "====================================="

backup() {
  target_path="$1"
  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    backup="${target_path}.back.$(date +%s)"
    echo "📦 Backing up existing $(basename "$target_path") to $backup"
    mv "$target_path" "$backup"
  fi
}

# Back up any real (unowned) files stow would otherwise collide with.
for item in themes extensions; do
  target="$PI_AGENT_DIR/$item"
  source_real="$(readlink -f "$SCRIPT_DIR/agent/$item")" 2>/dev/null || continue

  if [ -L "$target" ]; then
    [ "$(readlink -f "$target")" = "$source_real" ] && continue
    backup "$target"
  elif [ -e "$target" ]; then
    backup "$target"
  fi
done

mkdir -p "$PI_AGENT_DIR"
stow -d "$SCRIPT_DIR" -t "$PI_AGENT_DIR" agent

echo
echo "============================="
echo "✅ pi config links complete."