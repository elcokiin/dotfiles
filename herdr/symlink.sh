#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$HOME/.config/herdr/config.toml"

mkdir -p "$(dirname "$TARGET")"

if [ -L "$TARGET" ]; then
  rm "$TARGET"
elif [ -f "$TARGET" ]; then
  echo "Warning: $TARGET exists and is not a symlink, backing up to ${TARGET}.bak"
  mv "$TARGET" "${TARGET}.bak"
fi

ln -s "$DOTFILES_DIR/config.toml" "$TARGET"
echo "Symlinked: $TARGET -> $DOTFILES_DIR/config.toml"
