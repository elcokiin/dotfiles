#!/bin/sh

set -eu

if [ -n "${1:-}" ]; then
    BASE_DIR="$1"
else
    BASE_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
fi

DOTFILES_DIR="$BASE_DIR/hooks"
CONFIG_DIR="$HOME/.config/omarchy/hooks"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "❌ Error: hooks dotfiles directory not found: $DOTFILES_DIR"
    exit 1
fi

echo "Starting Omarchy hooks setup..."

mkdir -p "$CONFIG_DIR"

for src_file in "$DOTFILES_DIR"/*; do
    [ -f "$src_file" ] || continue

    filename=$(basename "$src_file")
    target_file="$CONFIG_DIR/$filename"

    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        if [ "$(readlink "$target_file")" = "$src_file" ]; then
            echo "✔️  $filename is already linked correctly."
            continue
        fi
        echo "📦 Backing up existing $filename to ${filename}.back"
        mv "$target_file" "${target_file}.back"
    fi

    echo "🔗 Linking $filename..."
    ln -sf "$src_file" "$target_file"

done

echo "Done! Your Omarchy hooks are safely linked."
