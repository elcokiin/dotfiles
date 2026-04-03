#!/bin/sh

set -eu

# If no parameter is given, use this script directory as base.
if [ -n "${1:-}" ]; then
    BASE_DIR="$1"
else
    BASE_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
fi

DOTFILES_DIR="$BASE_DIR/hypr"
CONFIG_DIR="$HOME/.config/hypr"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "❌ Error: Hypr dotfiles directory not found: $DOTFILES_DIR"
    exit 1
fi

echo "Starting Hyprland configuration setup..."

mkdir -p "$CONFIG_DIR"

for src_file in "$DOTFILES_DIR"/*; do
    [ -f "$src_file" ] || continue

    filename=$(basename "$src_file")

    # Skip any file that ends in .back inside your dotfiles folder
    if echo "$filename" | grep -q '\.back$'; then
        continue
    fi

    target_file="$CONFIG_DIR/$filename"

    # 3. Check if the file already exists in ~/.config/hypr
    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        # If it's ALREADY a symlink pointing directly to our dotfiles, just skip it
        if [ "$(readlink "$target_file")" = "$src_file" ]; then
            echo "✔️  $filename is already linked correctly."
            continue
        fi
        # If it exists but isn't our symlink, move it to .back
        echo "📦 Backing up existing $filename to ${filename}.back"
        mv "$target_file" "${target_file}.back"
    fi

    # 4. Create the symlink from your dotfiles to ~/.config/hypr
    echo "🔗 Linking $filename..."
    ln -sf "$src_file" "$target_file"

done

echo "Done! Your Hyprland configs are safely linked."

if [ -f "$DOTFILES_DIR/hyprlock.conf" ]; then
    target_hyprlock="$CONFIG_DIR/hyprlock.conf"
    source_hyprlock="$DOTFILES_DIR/hyprlock.conf"
    if [ -L "$target_hyprlock" ] && [ "$(readlink "$target_hyprlock")" = "$source_hyprlock" ]; then
        echo "✔️  hyprlock.conf is linked to dotfiles."
    else
        echo "⚠️  hyprlock.conf exists but is not linked to dotfiles source."
    fi
else
    echo "⚠️  hyprlock.conf is missing in dotfiles: $DOTFILES_DIR/hyprlock.conf"
fi
