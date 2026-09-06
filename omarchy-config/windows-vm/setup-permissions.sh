#!/bin/bash
# Fix common permission issues with omarchy-windows-vm
# Run this after fresh install or if launch fails silently

set -euo pipefail

echo "Checking Windows VM permissions..."

# Ensure source directories exist and are owned by current user
for dir in "$HOME/.windows" "$HOME/Windows"; do
  if [[ -d "$dir" ]]; then
    owner=$(stat -Lc '%u' "$dir")
    if [[ "$owner" != "$(id -u)" ]]; then
      echo "Fixing ownership of $dir"
      sudo chown "$(id -u):$(id -g)" "$dir"
    fi
    # Ensure mode is exactly 700 (no setgid)
    mode=$(stat -Lc '%a' "$dir")
    if [[ "$mode" != "700" ]]; then
      echo "Fixing mode of $dir ($mode -> 700)"
      chmod 700 "$dir"
    fi
  else
    echo "Creating $dir"
    mkdir -m 0700 "$dir"
  fi
done

echo "Done. Try: omarchy-windows-vm launch"
