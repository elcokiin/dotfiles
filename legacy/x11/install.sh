#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"
HOME_FILES_DIR="$SCRIPT_DIR/home"
TARGET_CONFIG_DIR="$HOME/.config"
TARGET_SCRIPTS_DIR="$HOME/.local/bin"
TARGET_SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
LOG_FILE="$SCRIPT_DIR/install.log"
WITH_USER_SYSTEMD=0

usage() {
  cat <<'EOF'
Usage: install.sh [--with-user-systemd] [--help]

Installs the legacy X11/bspwm dotfiles for the current user.

Options:
  --with-user-systemd  Link and enable the legacy battery monitor user timer.
  --help              Show this help.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --with-user-systemd)
      WITH_USER_SYSTEMD=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

backup_path() {
  local path="$1"
  local backup="${path}.legacy-backup.$(date +%s)"

  if [ -e "$path" ] || [ -L "$path" ]; then
    echo "Backing up $path -> $backup"
    mv "$path" "$backup"
  fi
}

link_entry() {
  local source="$1"
  local target="$2"

  if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$source")" ]; then
    echo "Already linked: $target"
    return
  fi

  backup_path "$target"
  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  echo "Linked: $target -> $source"
}

install_env_file() {
  local source="$HOME_FILES_DIR/.env.example"
  local target="$HOME/.env"

  if [ ! -f "$source" ]; then
    echo "Missing env template: $source" >&2
    exit 1
  fi

  backup_path "$target"
  sed "s#__LEGACY_X11_DIR__#$SCRIPT_DIR#g; s#__HOME__#$HOME#g" "$source" > "$target"
  echo "Generated: $target"
}

regenerate_templates() {
  if ! command -v envsubst >/dev/null 2>&1; then
    echo "Skipping template regeneration: envsubst is not installed."
    return
  fi

  set -a
  # shellcheck disable=SC1091
  source "$HOME/.env"
  set +a

  find "$SCRIPT_DIR" -type f -name "*.template" | while read -r template; do
    local output_file="${template%.template}"
    envsubst < "$template" > "$output_file"
    echo "Generated template: $output_file"
  done
}

install_user_systemd() {
  mkdir -p "$TARGET_SYSTEMD_USER_DIR"
  link_entry "$SCRIPT_DIR/systemd/battery-monitor.service" "$TARGET_SYSTEMD_USER_DIR/battery-monitor.service"
  link_entry "$SCRIPT_DIR/systemd/battery-monitor.timer" "$TARGET_SYSTEMD_USER_DIR/battery-monitor.timer"
  systemctl --user daemon-reload
  systemctl --user enable --now battery-monitor.timer
}

exec > >(tee "$LOG_FILE") 2>&1

echo "Starting legacy X11 install: $(date)"

mkdir -p "$TARGET_CONFIG_DIR" "$TARGET_SCRIPTS_DIR"

for folder in "$CONFIG_DIR"/*; do
  [ -d "$folder" ] || continue
  link_entry "$folder" "$TARGET_CONFIG_DIR/$(basename "$folder")"
done

for file in "$SCRIPTS_DIR"/*; do
  [ -f "$file" ] || continue
  link_entry "$file" "$TARGET_SCRIPTS_DIR/$(basename "$file")"
done

install_env_file
link_entry "$HOME_FILES_DIR/.gitconfig" "$HOME/.gitconfig"
link_entry "$HOME_FILES_DIR/.zsh_aliases" "$HOME/.zsh_aliases"
link_entry "$HOME_FILES_DIR/.zshrc" "$HOME/.zshrc"

regenerate_templates

if [ "$WITH_USER_SYSTEMD" -eq 1 ]; then
  install_user_systemd
else
  echo "Skipping battery monitor timer. Use --with-user-systemd to enable it."
fi

echo "Finished legacy X11 install: $(date)"
