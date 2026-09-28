#!/usr/bin/env bash
set -u

# Usage: launch.sh [--keep-alive]
#   --keep-alive  leave the container running after the RDP window closes

# Directory where this script lives (resolves symlinks)
DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
CONTAINER="windows"
RDP_SCRIPT="$DIR/execute-on-rdp-manual.sh"
LOG="/tmp/windows-vm-launch.log"
TIMEOUT=300 # max seconds to wait for Windows to respond

KEEP_ALIVE=0
[ "${1:-}" = "--keep-alive" ] && KEEP_ALIVE=1

exec > >(tee -a "$LOG") 2>&1
echo "=== $(date) ==="

notify() { notify-send -a "Windows VM" "$1" 2>/dev/null || true; }

# 1. Is the container running?
if [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null)" != "true" ]; then
  echo "Container is stopped, starting it..."
  notify "Starting Windows..."
  if ! (cd "$DIR" && docker compose up -d); then
    notify "Error: could not start the container (check $LOG)"
    exit 1
  fi
else
  echo "Container is already running."
fi

# 2. Wait for Windows to answer over RDP
# (host port 3389 opens before Windows is actually ready, so we send an
# X.224 Connection Request and check that we get a response back)
rdp_ready() {
  printf '\x03\x00\x00\x13\x0e\xe0\x00\x00\x00\x00\x00\x01\x00\x08\x00\x03\x00\x00\x00' |
    timeout 3 nc -w 2 127.0.0.1 3389 2>/dev/null | head -c1 | grep -q .
}

echo "Waiting for Windows to respond over RDP..."
elapsed=0
until rdp_ready; do
  if [ "$elapsed" -ge "$TIMEOUT" ]; then
    notify "Windows did not respond within ${TIMEOUT}s (check $LOG)"
    exit 1
  fi
  sleep 3
  elapsed=$((elapsed + 3))
done
echo "RDP ready after ~${elapsed}s."

# 3. Run the RDP script (blocks until the RDP window is closed)
"$RDP_SCRIPT"

# 4. Shut the VM down to free RAM/CPU, unless --keep-alive was given
if [ "$KEEP_ALIVE" -eq 0 ]; then
  echo "RDP closed, stopping container..."
  notify "Shutting down Windows..."
  (cd "$DIR" && docker compose stop)
else
  echo "RDP closed, leaving container running (--keep-alive)."
fi
