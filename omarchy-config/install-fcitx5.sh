#!/bin/sh

set -eu

# If no parameter is given, use this script directory as base.
if [ -n "${1:-}" ]; then
    BASE_DIR="$1"
else
    BASE_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
fi

DOTFILES_DIR="$BASE_DIR/fcitx5"
CONFIG_DIR="$HOME/.config/fcitx5"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "❌ Error: Fcitx5 dotfiles directory not found: $DOTFILES_DIR"
    exit 1
fi

echo "Starting Fcitx5 configuration setup..."

mkdir -p "$CONFIG_DIR"
mkdir -p "$CONFIG_DIR/conf"

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

if [ -f "$DOTFILES_DIR/conf/cached_layouts" ]; then
    target_cached_layouts="$CONFIG_DIR/conf/cached_layouts"
    source_cached_layouts="$DOTFILES_DIR/conf/cached_layouts"

    if [ -e "$target_cached_layouts" ] || [ -L "$target_cached_layouts" ]; then
        if [ "$(readlink "$target_cached_layouts")" = "$source_cached_layouts" ]; then
            echo "✔️  conf/cached_layouts is already linked correctly."
        else
            echo "📦 Backing up existing conf/cached_layouts to cached_layouts.back"
            mv "$target_cached_layouts" "${target_cached_layouts}.back"
            echo "🔗 Linking conf/cached_layouts..."
            ln -sf "$source_cached_layouts" "$target_cached_layouts"
        fi
    else
        echo "🔗 Linking conf/cached_layouts..."
        ln -sf "$source_cached_layouts" "$target_cached_layouts"
    fi
fi

echo "Done! Your Fcitx5 configs are safely linked."
