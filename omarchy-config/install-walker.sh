#!/bin/sh

# Check if the user provided the dotfiles path as a parameter
if [ -z "$1" ]; then
    echo "❌ Error: Please provide the path to your dotfiles directory."
    echo "Usage: $0 <path-to-dotfiles>"
    exit 1
fi

# Define your source and target directories using the parameter ($1)
BASE_DIR="$1"
DOTFILES_WALKER="$BASE_DIR/walker"
TARGET_WALKER="$HOME/.config/walker"

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
