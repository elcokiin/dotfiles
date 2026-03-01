#!/bin/sh

# Exit immediately if any command fails
set -e

PACKAGE="nvim"
TARGET_DIR="$HOME/.config/$PACKAGE"
# Create a unique backup name using the current date and time
BACKUP_DIR="$HOME/.config/${PACKAGE}_backup_$(date +%s)"

echo "🚀 Starting Neovim configuration setup..."
  echo "========================================"

# 1. Check if stow is actually installed
if ! command -v stow >/dev/null 2>&1; then
    echo "❌ Error: 'stow' is not installed. Please install it first."
    exit 1
fi

# 2. Ensure the parent ~/.config directory exists
mkdir -p "$HOME/.config"

# 3. Handle existing configurations to prevent Stow conflicts
if [ -e "$TARGET_DIR" ] || [ -L "$TARGET_DIR" ]; then
    echo "📦 Found existing Neovim config at $TARGET_DIR."
    echo "🔄 Moving it to $BACKUP_DIR to prevent symlink conflicts..."
    mv "$TARGET_DIR" "$BACKUP_DIR"
fi

# 4. Create a fresh, empty target directory for Stow to use
mkdir -p "$TARGET_DIR"

# 5. Run Stow to link the files
# We use the explicit target (-t) to link into ~/.config/nvim
echo "🔗 Stowing '$PACKAGE' into '$TARGET_DIR'..."
stow -t "$TARGET_DIR" "$PACKAGE"

echo "========================================"
echo "✅ Neovim configuration successfully stowed!"
