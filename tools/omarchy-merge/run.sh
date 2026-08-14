#!/usr/bin/env bash
#
# omarchy-merge — launch an interactive opencode session that merges your
# custom dotfiles with the current Omarchy defaults.
#
# Merges happen ONLY inside this repository (repo-first, symlinks later).
# The agent follows tools/omarchy-merge/prompt.md (the runbook) and asks you
# before writing anything you haven't confirmed, per component.
#
# Usage:
#   ./run.sh                        # all components, interactive TUI
#   ./run.sh --only hypr            # scope to one component
#   ./run.sh --only hypr,herdr      # scope to several
#   ./run.sh --print                # print the composed prompt, don't launch
#   ./run.sh --headless             # non-interactive: opencode run
#   ./run.sh --model provider/model # pick the model for the session
#   ./run.sh --help
#
# Supported components: hypr herdr nvim

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "${SCRIPT_DIR}/../.." && pwd)"

PROMPT_FILE="${SCRIPT_DIR}/prompt.md"
DECISIONS_FILE="${SCRIPT_DIR}/decisions.md"

ALL_COMPONENTS=("hypr" "herdr" "nvim")
SCOPE=()
HEADLESS=0
PRINT_ONLY=0
MODEL=""

usage() {
  sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit 0
}

die() {
  echo "error: $*" >&2
  exit 1
}

while (($#)); do
  case "$1" in
    --only)
      [[ -n "${2:-}" ]] || die "--only requires a value"
      IFS=',' read -r -a _parts <<<"$2"
      SCOPE+=("${_parts[@]}")
      shift 2
      ;;
    --headless)
      HEADLESS=1
      shift
      ;;
    --print)
      PRINT_ONLY=1
      shift
      ;;
    --model)
      [[ -n "${2:-}" ]] || die "--model requires a value"
      MODEL="$2"
      shift 2
      ;;
    -h | --help)
      usage
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
done

# Default scope = everything.
if ((${#SCOPE[@]} == 0)); then
  SCOPE=("${ALL_COMPONENTS[@]}")
fi

# Validate scope values.
for c in "${SCOPE[@]}"; do
  case " ${ALL_COMPONENTS[*]} " in
    *" $c "*) ;;
    *) die "unknown component '$c' (supported: ${ALL_COMPONENTS[*]})" ;;
  esac
done

# Preflight.
command -v opencode >/dev/null 2>&1 || die "opencode not found on PATH"
[[ -f "$PROMPT_FILE" ]] || die "missing $PROMPT_FILE"
[[ -f "$DECISIONS_FILE" ]] || die "missing $DECISIONS_FILE"
git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
  die "not a git repository: $REPO_ROOT"

# Safety: this tool merges repo files only; refuse to run from the live config.
case "$PWD" in
  "$HOME"/.config) die "refusing to run from ~/.config — merges are repo-only" ;;
  "$HOME"/.config/*) die "refusing to run from ~/.config/... — merges are repo-only" ;;
esac

# Compose the prompt: runbook + scope note.
scope_text=""
for c in "${SCOPE[@]}"; do
  scope_text+="- ${c}"$'\n'
done
PROMPT="$(<"$PROMPT_FILE")"
PROMPT="${PROMPT//__COMPONENTS__/${scope_text}}"

if ((PRINT_ONLY)); then
  printf '%s\n' "$PROMPT"
  exit 0
fi

extra=()
[[ -n "$MODEL" ]] && extra+=(--model "$MODEL")

echo "repo:     $REPO_ROOT"
echo "scope:    ${SCOPE[*]}"
echo "runbook:  $PROMPT_FILE"
echo "decisions: $DECISIONS_FILE"
echo

if ((HEADLESS)); then
  echo "Launching headless opencode run…"
  exec opencode run "${extra[@]}" --dir "$REPO_ROOT" --title "omarchy-merge ${SCOPE[*]}" "$PROMPT"
fi

echo "Launching interactive opencode TUI…"
exec opencode --prompt "$PROMPT" "${extra[@]}" "$REPO_ROOT"