#!/usr/bin/env bash
#
# hash-renamer.sh - rename marker files "##name##rest" to "name-v#-dd-mm-yyyy-rest".
#
# Files whose name does not start with "##" are never scanned. Files that start
# with "##" but have no second "##" (no ##name## structure) are left untouched.
# The file content is never modified - only the name changes.
#
# Example:
#   folder has:  hola-v1-06-10-2026-algo.txt  hola-v2-07-10-2026-otra.txt
#   new file:    ##hola##pero-que-pasa.txt
#   renamed to:  hola-v3-06-10-2026-pero-que-pasa.txt
#
# Usage:
#   hash-renamer.sh                 one scan pass over $HOME (default)
#   hash-renamer.sh --watch         daemon: scan every --interval seconds
#
# Options:
#   --root DIR        scan DIR instead of $HOME
#   --interval SECS   watch-mode interval (default 10, env HASH_RENAMER_INTERVAL)
#   --settle SECS     watch mode: ignore files modified in the last SECS
#                     (default 3, avoids renaming files still being written;
#                      scan mode defaults to 0)
#   --dry-run         print what would be renamed, touch nothing
#   --no-notify       do not send desktop notifications
#   --verbose         also report skipped/non-matching ## files
#   --help            show this help

set -euo pipefail

ROOT="${HOME}"
MODE="scan"
INTERVAL="${HASH_RENAMER_INTERVAL:-10}"
SETTLE=""
DRY=0
NOTIFY=1
VERBOSE=0

# Basename-glob excludes (fd) / -name excludes (find): caches, toolchains,
# package stores, VCS metadata, app profiles. User folders (Documents,
# Downloads, Desktop, Work, ...) are always scanned.
JUNK_DIRS=(
  .cache
  .npm
  .local
  .config
  .herdr
  .gradle
  .bun
  .rustup
  .cargo
  .vscode
  .windows
  .paseo
  .gemini
  .codex
  .antigravity
  .cursor
  .maestro
  .minecraft
  .tlauncher
  Games
  Android
  node_modules
  .git
)

usage() {
  sed -n '3,26p' "$0" | sed 's/^# \{0,1\}//'
}

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

notify() {
  [ "$NOTIFY" -eq 1 ] || return 0
  local old="$1" new="$2"
  if command -v omarchy-notification-send >/dev/null 2>&1; then
    omarchy-notification-send -u low "File renamed" "$old -> $new" >/dev/null 2>&1 || true
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send -u low "File renamed" "$old -> $new" >/dev/null 2>&1 || true
  fi
}

# Print NUL-delimited paths of files named ##* under $ROOT.
list_files() {
  if command -v fd >/dev/null 2>&1; then
    local args=() d
    for d in "${JUNK_DIRS[@]}"; do
      args+=(--exclude "$d")
    done
    fd -H --no-ignore -0 -t f '^##' "$ROOT" "${args[@]}" 2>/dev/null || true
  else
    local prune=() d first=1
    for d in "${JUNK_DIRS[@]}"; do
      [ "$first" -eq 1 ] || prune+=(-o)
      first=0
      prune+=(-name "$d")
    done
    find "$ROOT" \( "${prune[@]}" \) -prune -o -type f -name '##*' -print0 \
      2>/dev/null || true
  fi
}

# Rename one file if its name has the ##name##rest structure.
# Always returns 0; individual failures are logged, never fatal.
rename_file() {
  local src="$1"
  local dir base rest name tail
  dir=$(dirname -- "$src")
  base=$(basename -- "$src")

  rest="${base#\#\#}"                       # strip leading ##
  case "$rest" in
    *'##'*) ;;
    *)
      # Starts with ## but has no ##name## structure: leave untouched.
      if [ "$VERBOSE" -eq 1 ]; then
        log "skip (no second ##): $base"
      fi
      return 0
      ;;
  esac

  name="${rest%%\#\#*}"                     # up to the next ##
  tail="${rest#*\#\#}"                      # after the next ##

  if [ -z "$name" ] || [ -z "$tail" ]; then
    if [ "$VERBOSE" -eq 1 ]; then
      log "skip (empty name or rest): $base"
    fi
    return 0
  fi

  # Watch mode: skip files modified moments ago (still being written).
  if [ "$MODE" = "watch" ] && [ "$SETTLE" -gt 0 ]; then
    local now mt
    now=$(date +%s)
    mt=$(stat -c %Y -- "$src" 2>/dev/null) || return 0
    if [ $((now - mt)) -lt "$SETTLE" ]; then
      return 0
    fi
  fi

  # Count existing versioned files with the same name in this folder.
  local count=0 f ver
  shopt -s nullglob
  for f in "$dir/$name"-v[0-9]*; do
    if [ -f "$f" ]; then
      count=$((count + 1))
    fi
  done
  ver=$((count + 1))

  local dst_date dst
  dst_date=$(date +%d-%m-%Y)
  dst="$dir/$name-v$ver-$dst_date-$tail"

  # Guarantee a unique version number even if versions have gaps or the exact
  # target name already exists.
  while :; do
    local clash=0
    for f in "$dir/$name-v$ver"-*; do
      clash=1
      break
    done
    if [ "$clash" -eq 0 ] && [ ! -e "$dst" ]; then
      break
    fi
    ver=$((ver + 1))
    dst="$dir/$name-v$ver-$dst_date-$tail"
  done
  shopt -u nullglob

  if [ "$DRY" -eq 1 ]; then
    log "would rename: $base -> ${dst##*/}"
    return 0
  fi

  if mv -- "$src" "$dst"; then
    log "renamed: $base -> ${dst##*/}"
    notify "$base" "${dst##*/}"
  else
    log "ERROR: mv failed: $base"
  fi
  return 0
}

scan() {
  local src
  while IFS= read -r -d '' src; do
    rename_file "$src"
  done < <(list_files)
  return 0
}

# --- arguments ---------------------------------------------------------------

while [ "$#" -gt 0 ]; do
  case "$1" in
    --watch) MODE="watch"; shift ;;
    --scan) MODE="scan"; shift ;;
    --root)
      [ "$#" -ge 2 ] || { echo "missing value for --root" >&2; exit 2; }
      ROOT="$2"; shift 2 ;;
    --interval)
      [ "$#" -ge 2 ] || { echo "missing value for --interval" >&2; exit 2; }
      INTERVAL="$2"; shift 2 ;;
    --settle)
      [ "$#" -ge 2 ] || { echo "missing value for --settle" >&2; exit 2; }
      SETTLE="$2"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    --no-notify) NOTIFY=0; shift ;;
    --verbose) VERBOSE=1; shift ;;
    -h | --help) usage; exit 0 ;;
    *) echo "unknown option: $1 (see --help)" >&2; exit 2 ;;
  esac
done

[ -d "$ROOT" ] || { echo "root directory not found: $ROOT" >&2; exit 2; }

if [ -z "$SETTLE" ]; then
  if [ "$MODE" = "watch" ]; then SETTLE=3; else SETTLE=0; fi
fi

# Single instance (a live watch daemon would fight a manual scan).
if [ "$DRY" -eq 0 ]; then
  LOCK="${XDG_RUNTIME_DIR:-/tmp}/hash-renamer.${USER:-user}.lock"
  exec 9>"$LOCK"
  if ! flock -n 9; then
    echo "hash-renamer: another instance is already running" >&2
    exit 0
  fi
fi

# --- run ---------------------------------------------------------------------

if [ "$MODE" = "scan" ]; then
  scan
else
  trap 'exit 0' INT TERM
  log "watch mode: root=$ROOT interval=${INTERVAL}s settle=${SETTLE}s"
  while :; do
    scan
    sleep "$INTERVAL"
  done
fi
