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
CONFIG_CONF_DIR="$CONFIG_DIR/conf"
THEMES_DOTFILES_DIR="$DOTFILES_DIR/themes"
THEMES_TARGET_DIR="$HOME/.local/share/fcitx5/themes"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "❌ Error: Fcitx5 dotfiles directory not found: $DOTFILES_DIR"
    exit 1
fi

echo "Starting Fcitx5 configuration setup..."

mkdir -p "$CONFIG_DIR"
mkdir -p "$CONFIG_CONF_DIR"

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

if [ -d "$DOTFILES_DIR/conf" ]; then
    for src_conf in "$DOTFILES_DIR"/conf/*; do
        [ -f "$src_conf" ] || continue

        conf_name=$(basename "$src_conf")
        target_conf="$CONFIG_CONF_DIR/$conf_name"

        if [ -e "$target_conf" ] || [ -L "$target_conf" ]; then
            if [ "$(readlink "$target_conf")" = "$src_conf" ]; then
                echo "✔️  conf/$conf_name is already linked correctly."
                continue
            fi
            echo "📦 Backing up existing conf/$conf_name to ${conf_name}.back"
            mv "$target_conf" "${target_conf}.back"
        fi

        echo "🔗 Linking conf/$conf_name..."
        ln -sf "$src_conf" "$target_conf"
    done
fi

if [ -d "$THEMES_DOTFILES_DIR" ]; then
    mkdir -p "$THEMES_TARGET_DIR"

    for src_theme in "$THEMES_DOTFILES_DIR"/*; do
        [ -d "$src_theme" ] || continue

        theme_name=$(basename "$src_theme")
        target_theme="$THEMES_TARGET_DIR/$theme_name"

        if [ -e "$target_theme" ] || [ -L "$target_theme" ]; then
            if [ "$(readlink "$target_theme")" = "$src_theme" ]; then
                echo "✔️  theme/$theme_name is already linked correctly."
                continue
            fi
            echo "📦 Backing up existing theme/$theme_name to ${theme_name}.back"
            mv "$target_theme" "${target_theme}.back"
        fi

        echo "🔗 Linking theme/$theme_name..."
        ln -s "$src_theme" "$target_theme"
    done
fi

echo "Done! Your Fcitx5 configs are safely linked."
