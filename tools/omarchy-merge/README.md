ALL OF THIS TOOL IS AI SLOP SO CAN CONTAIN ERRORS, NO TESTED YET


# omarchy-merge

Launch an interactive opencode session that merges your custom dotfiles with
the current Omarchy defaults. Merges are written **only inside this repo**
(repo-first; symlinking into `~/.config` is a separate, later step).

The session follows `prompt.md` (the runbook): component by component it
compares your dotfiles against Omarchy's defaults, reports every delta as
*kept (mine) / adopted (omarchy) / dropped / merged*, shows the side-by-side
for anything that collides, and asks you before writing — so you decide what
goes in, exactly like the original merge session this tool was distilled from.

## Files

| File | Purpose |
| --- | --- |
| `run.sh` | Bash launcher (simple → bash). Builds the prompt and opens opencode. |
| `prompt.md` | The repeatable runbook/agent instructions: goals, hard rules, per-component step-by-step, validation, finish. |
| `decisions.md` | Your already-resolved decisions for the current Omarchy release (`quattro` / Hyprland v0.56.x). Starts the run fast; the agent still confirms per component. |

## Usage

```sh
./tools/omarchy-merge/run.sh                  # all components (hypr, herdr, nvim)
./tools/omarchy-merge/run.sh --only hypr      # one component
./tools/omarchy-merge/run.sh --only hypr,nvim
./tools/omarchy-merge/run.sh --print          # preview the composed prompt
./tools/omarchy-merge/run.sh --headless       # non-interactive `opencode run`
./tools/omarchy-merge/run.sh --model provider/model
```

Default behavior: opens the full interactive opencode TUI preloaded with the
merged prompt (`opencode --prompt`), running in the repo root. Answer the
agent as it walks each component.

## How the merge is decided

1. **Base** = Omarchy's current default for the component
   (`$OMARCHY_PATH` = `/usr/share/omarchy` by default).
2. **Top layer** = your custom values from this repo.
3. Each delta is classified `CUSTOM-ONLY / OMARCHY-ONLY / CONFLICT`.
4. `CONFLICT`s and proposed adoptions are shown side-by-side and decided with
   you; `decisions.md` is your prior intent so it isn't re-litigated.
5. Merged files are written into the repo; the run finishes with a kept /
   adopted / dropped table and an explicit ask about committing.

## Rules enforced by the runbook

- **Repo-only**: no edits to `~/.config`, `~/.local`, or anywhere outside this
  repo during the merge phase.
- **Omarchy read-only**: `/usr/share/omarchy` is never modified.
- **Ask first**: nothing is applied silently or in bulk; one component at a time.
- **No commits** without explicit approval.

## After the merge

1. Review the repo diff: `git -C <repo> diff --stat`.
2. Apply to the live system with your existing link scripts:
   `./omarchy-config/bootstrap.sh` (hypr/fcitx5/hooks), `herdr/symlink.sh`,
   `./omarchy-config/install-nvim.sh`. (Bring these up to date first if the
   merged files renamed anything.)
3. Validate live: `hyprctl reload && hyprctl configerrors`, `herdr config
   check`, restart the shell/bar.
