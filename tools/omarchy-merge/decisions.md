# Omarchy merge decisions (quattro · Hyprland v0.56.x)

Prior intent distilled from a real merge session. The agent re-confirms per
component before applying these — this file only stops already-resolved items
from being re-litigated line-by-line.

## Components in scope

- `hypr`, `herdr`, `nvim`
- Deferred / legacy (not linked this pass): `fcitx5` (CJK input method + layout
  toggle; its `config`/`profile` were overwritten by the update), `walker`
  (launcher replaced by quattro's `omarchy-menu`, `omacalc`, `omarchy.clipboard`).

## hypr (Lua config, v0.56+)

Hyprland config moved from `.conf` to Lua modules loaded by `hyprland.lua`:
`hypr.monitors`, `hypr.input`, `hypr.bindings`, `hypr.looknfeel`,
`hypr.autostart`. Defaults live in `$OMARCHY_PATH/default/hypr/*.lua`. The old
`.conf` override files are **no longer loaded** — they were the reason my
settings silently broke after the upgrade.

### input.lua
- `touchpad.natural_scroll = true` — restore (default is `false`; this was the
  inverted scroll).
- Keep Omarchy defaults: `kb_options = "compose:caps,shift:both_capslock_cancel"`
  (compose key on caps — intentional), `scroll_factor = 0.4`,
  `disable_while_typing`, `numlock_by_default`, `kb_layout` from vconsole.
- No language-toggle binding. Language switch stays on fcitx5's own
  `Ctrl+Space`.

### bindings.lua
Keep **mine**:
| Key | Action |
| --- | ------ |
| `SUPER + SHIFT + A` | Gemini (webapp) |
| `SUPER + SHIFT + ALT + A` | Claude (webapp) |
| `SUPER + SHIFT + C` | Calendar — Google Calendar |
| `SUPER + SHIFT + E` | Excalidraw |
| `SUPER + SHIFT + ALT + E` | Email — Gmail |
| `SUPER + SHIFT + ALT + F` | Fast Finger Test |
| `SUPER + SHIFT + G` | WhatsApp |
| `SUPER + SHIFT + O` | Remnote |
| `SUPER + SHIFT + S` | Screenshot (`omarchy-capture-screenshot`) |
| `SUPER + C` | Copy history = `omarchy-shell shell toggle omarchy.clipboard` |

Keep **Omarchy default** (do not override):
| Key | Action |
| --- | ------ |
| `SUPER + SHIFT + ALT + M` | Music TUI (cliamp) |
| `SUPER + SHIFT + N` | Editor |

Free-key **additions** (no default clash):
| Key | Action |
| --- | ------ |
| `SUPER + A` | Grok (webapp) |
| `SUPER + SHIFT + ALT + C` | Chess |
| `SUPER + ALT + C` | Calculator (`omacalc`) |
| `SUPER + SHIFT + ALT + N` | Editor |
| `SUPER + SHIFT + ALT + O` | Obsidian |

Dropped on purpose (defaults now own the keys, and the app is reachable
another way): ChatGPT/Grok(alt) on `S+SHIFT+(ALT+)A`, HEY Calendar/Email/New
email, Signal, Notion, Obsidian(on `S+SHIFT+O`), Moodle, Google Maps,
Universal copy on `S+C`, walker clipboard/calc.

- No caps-lock `code:66` language toggle binding (caps = compose; layout switch
  is fcitx `Ctrl+Space`).

### autostart.lua
- `o.launch_on_start("paseo")` (restore; the update dropped `exec-once = paseo`).

### monitors.lua
- `omarchy_monitor_scale = 1.25` + `GDK_SCALE` env (already migrated) — keep.
- Lid / clamshell: handled by Omarchy defaults (`omarchy-system-lid-close` +
  `omarchy-hyprland-monitor-clamshell`). Do NOT restore the old `bindl` eDP-1
  disable lines; the default re-enables eDP-1 at the scale read from
  `monitors.lua`.

### idle, lock, night light
- Idle: keep Omarchy default `shell.json` (`idle.lock` 300s / `screensaver`
  150s). Old `hypridle.conf` timing (152s lock) deliberately dropped.
- Lock: hyprlock is **not used** in quattro — `omarchy-system-lock` calls
  `omarchy-shell lock lock` (Quickshell `omarchy.lock` overlay). `hyprlock.conf`
  moved to `legacy/omarchy/hypr/`.

### Stale files to remove/move after merge
- `omarchy-config/hypr/input.conf`, `bindings.conf`, `monitors.conf`,
  `autostart.conf`, `hypridle.conf`, `hyprdle.conf.back` — superseded by the
  `.lua` files (git history preserves them); ask user delete vs legacy.

## herdr

`herdr/config.toml` = herdr's current default config as base, plus my custom
keys re-added under `[keys]`:

```toml
[keys]
focus_agent = "prefix+alt+1..9"
navigate_workspace_up = "k"
navigate_workspace_down = "j"
```

(`onboarding = false` is already part of the new default.)

## nvim

`omarchy-config/nvim/` holds the full LazyVim config. Add back the file that
only exists in the live config:

- `lua/config/remote_clipboard.lua` — OSC 52 / tmux / herdr remote clipboard.

## Legacy (moved, not linked, not bootstrapped)

- `legacy/omarchy/hypr/hyprlock.conf`
- `legacy/omarchy/walker/` (walker config) — plus remove the walker step from
  `bootstrap.sh` and the README references. Walker isn't used by quattro.