#!/bin/sh

set -eu

if [ -n "${1:-}" ]; then
    BASE_DIR="$1"
else
    BASE_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
fi

DOTFILES_TMUX="$BASE_DIR/tmux-before-native"
TARGET_TMUX="$HOME/.config/tmux"

if [ ! -d "$DOTFILES_TMUX" ]; then
    echo "❌ Error: tmux dotfiles directory not found: $DOTFILES_TMUX"
    exit 1
fi

backup_path() {
    path="$1"
    if [ -e "$path" ] || [ -L "$path" ]; then
        backup="${path}.back.$(date +%s)"
        echo "📦 Backing up existing $path to $backup"
        mv "$path" "$backup"
    fi
}

link_file() {
    source_file="$1"
    target_file="$2"

    if [ -L "$target_file" ] && [ "$(readlink -f "$target_file")" = "$(readlink -f "$source_file")" ]; then
        echo "✔️  $(basename "$target_file") is already linked correctly."
        return
    fi

    backup_path "$target_file"
    ln -s "$source_file" "$target_file"
    echo "🔗 Linked $target_file"
}

echo "Starting tmux configuration setup..."
mkdir -p "$TARGET_TMUX"

link_file "$DOTFILES_TMUX/tmux.conf" "$TARGET_TMUX/tmux.conf"
link_file "$DOTFILES_TMUX/omarchy-current-theme.conf" "$TARGET_TMUX/omarchy-current-theme.conf"

echo "Done! Your tmux config is safely linked."
