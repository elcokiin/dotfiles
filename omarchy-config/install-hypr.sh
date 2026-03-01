#!/bin/sh

# Check if the user provided the dotfiles path as a parameter
if [ -z "$1" ]; then
    echo "❌ Error: Please provide the path to your dotfiles directory."
    echo "Usage: $0 <path-to-dotfiles>"
    exit 1
fi

# Define your source and target directories using the parameter ($1)
BASE_DIR="$1"
DOTFILES_DIR="$BASE_DIR/hypr"
CONFIG_DIR="$HOME/.config/hypr"

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
