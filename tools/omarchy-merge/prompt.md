# Omarchy dotfiles merge runbook

You are going to merge my custom dotfiles with the current Omarchy defaults.
This runbook is a repeatable procedure distilled from a real merge session
against the `quattro` release (Hyprland v0.56.x), which switched Hyprland config
from `.conf` files to Lua modules.

## Objective

For each component in scope, take Omarchy's current default as the base and
re-apply my custom values on top, producing the **merged config files inside
this repository only**. Whenever my custom values collide with an Omarchy
default, show me both and let me decide. Nothing is applied to the live system
in this phase — symlinks happen later in a separate step.

## Hard rules

- **REPO-ONLY.** Never edit or create anything under `~/.config`, `~/.local`,
  or any path outside this repository in this phase. All output is written into
  this repo (e.g. `omarchy-config/`, `.config/herdr/`).
- **OMARCHY READ-ONLY.** `/usr/share/omarchy` (and `$OMARCHY_PATH`) is
  read-only. Reading defaults from there is encouraged; modifying it is
  forbidden.
- **ASK FIRST.** For every conflict and for every new default you propose to
  adopt, ask me before writing. Never apply silently or in bulk.
- **ONE COMPONENT AT A TIME.** Process a single component, show its summary,
  and wait for my "continue" before starting the next.

## Inputs

- My custom dotfiles in this repo: `omarchy-config/` (hypr, nvim, fcitx5) and
  `.config/herdr/`.
- Omarchy defaults: `$OMARCHY_PATH` (default `/usr/share/omarchy`) plus any
  live `~/.config/*` files as read-only reference for comparison.
- `tools/omarchy-merge/decisions.md` — decisions I already resolved for this
  release. Treat them as my prior intent: do not re-litigate them line by line,
  but confirm each component before applying.

## Scope for this run

__COMPONENTS__

## Step-by-step

For each component in scope:

1. **INVENTORY.** List my custom files and the matching Omarchy default files.
   - hypr: compare `omarchy-config/hypr/*` against
     `/usr/share/omarchy/default/hypr/*.lua` (and `/usr/share/omarchy/config`).
   - herdr: `.config/herdr/config.toml` against herdr's shipped defaults.
   - nvim: `omarchy-config/nvim/` against Omarchy's nvim default (if any) and
     against what the live `~/.config/nvim` currently has.

2. **CLASSIFY** each delta:
   - `CUSTOM-ONLY` — in my dotfiles but not in Omarchy defaults.
   - `OMARCHY-ONLY` — in defaults but not in my dotfiles (a feature I'd gain).
   - `CONFLICT` — both set the same key / option / file.

3. **REPORT** each delta in this shape:
   - CUSTOM-ONLY: "keep `{setting}` from my config (no default counterpart)"
   - OMARCHY-ONLY: "adopt default `{setting}` (missing from mine): <snippet>"
   - CONFLICT: "my `{setting}` = `{mine}` vs omarchy `{default}` → which wins?"

4. **DECIDE WITH ME.** For conflicts and for any adoption you propose, show me
   a side-by-side and wait for my answer: *keep mine / keep default / drop both /
   merge*. Default to `decisions.md` when present, but confirm it in one
   summary at the start of the component rather than asking each line twice.

5. **WRITE** the merged file in the repo, custom winning unless I said
   otherwise. Keep the exact filename/structure the live config expects for
   this release (hypr: `input.lua`, `bindings.lua`, `autostart.lua`,
   `monitors.lua`, `looknfeel.lua`; herdr: `.config/herdr/config.toml`; nvim:
   LazyVim layout).

6. **SUMMARY + GATE.** After each component print a table:

   | kept (mine)      | adopted (omarchy)         | dropped | merged / deduped |
   | ---------------- | ------------------------- | ------- | ---------------- |
   | ...              | ...                       | ...     | ...              |

   then stop and wait for my "continue".

## Validation (repo-only)

- Lua files: `luac -p <file>`,

  on a missing binary fall back to `lua -e "assert(loadfile('<file>'))"`.
- herdr: `herdr config check` reads the real config path, so defer full
  validation to the symlink phase; now just sanity-check key names against
  `herdr --help`.
- Shell/TOML: basic syntax sanity.
- Finish with `git -C <repo root> status --short`.

## Finish

- Final summary: per component, what was kept / adopted / dropped and which
  files changed.
- List stale files now unused (old `.conf` overrides, legacy candidates) and
  ask me whether to delete or move them to `legacy/`.
- Ask whether I want a git commit. **Never commit without my explicit approval.**