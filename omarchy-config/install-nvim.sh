#!/bin/sh

set -eu

PACKAGE="nvim"
if [ -n "${1:-}" ]; then
    BASE_DIR="$1"
else
    BASE_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
fi

PACKAGE_DIR="$BASE_DIR/$PACKAGE"
TARGET_DIR="$HOME/.config/$PACKAGE"
BACKUP_DIR="$HOME/.config/${PACKAGE}_backup_$(date +%s)"

echo "🚀 Starting Neovim configuration setup..."
  echo "========================================"

# 1. Check if stow is actually installed
if ! command -v stow >/dev/null 2>&1; then
    echo "❌ Error: 'stow' is not installed. Please install it first."
    exit 1
fi

if [ ! -d "$PACKAGE_DIR" ]; then
    echo "❌ Error: Neovim dotfiles directory not found: $PACKAGE_DIR"
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
(
    cd "$BASE_DIR"
    stow -t "$TARGET_DIR" "$PACKAGE"
)

echo "========================================"
echo "✅ Neovim configuration successfully stowed!"
