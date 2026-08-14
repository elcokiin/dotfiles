#!/bin/sh

set -eu

# If no parameter is given, use this script directory as base.
if [ -n "${1:-}" ]; then
    BASE_DIR="$1"
else
    BASE_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
fi

DOTFILES_WALKER="$BASE_DIR/walker"
TARGET_WALKER="$HOME/.config/walker"

if [ ! -d "$DOTFILES_WALKER" ]; then
    echo "❌ Error: Walker dotfiles directory not found: $DOTFILES_WALKER"
    exit 1
fi

echo "Starting Walker configuration setup..."

# 1. Check if ~/.config/walker already exists
if [ -e "$TARGET_WALKER" ] || [ -L "$TARGET_WALKER" ]; then
    
    # If it's ALREADY a symlink pointing to our dotfiles, skip it and finish
    if [ "$(readlink "$TARGET_WALKER")" = "$DOTFILES_WALKER" ]; then
        echo "✔️  Walker folder is already linked correctly."
        exit 0
    fi
    
    # If it exists but isn't our symlink, back it up!
    echo "📦 Backing up existing Walker config to walker.back..."
    rm -rf "${TARGET_WALKER}.back"
    mv "$TARGET_WALKER" "${TARGET_WALKER}.back"
fi

# 2. Create the symlink for the entire folder
echo "🔗 Linking the walker folder..."
ln -sf "$DOTFILES_WALKER" "$TARGET_WALKER"

echo "Done! Your Walker config is safely linked."
