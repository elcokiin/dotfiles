# pi — global config

Global config for [pi](https://pi.dev/) (AI coding assistant). This folder is
the source of truth; it is synced via these dotfiles and stowed into
`~/.pi/agent`.

pi reads its config from `~/.pi/agent` (default of `PI_CODING_AGENT_DIR`).

## What is tracked

- `agent/themes/` — custom interactive themes
- `agent/extensions/` — custom pi extensions

## What is NOT tracked (stays on the machine)

Secrets, runtime state, skills, and the settings file are left out of dotfiles
on purpose (dmmulroy approach — see `.pi/.gitignore`):

- `agent/settings.json` — pi owns this at runtime (provider/model/theme state,
  `lastChangelogVersion`, packages). It mutates on every pi update, so it is
  gitignored and stays machine-local. Reconfigure per machine with `pi auth`
  / `pi config`.
- `~/.pi/agent/auth.json` (API keys/tokens)
- `~/.pi/agent/models-store.json`, `~/.pi/agent/trust.json`
- `~/.pi/agent/sessions/` (session history)
- `~/.pi/agent/skills/` — skills are **global** (synced from `~/.agents/skills`)
  and auto-discovered by every agent; pi picks them up without any folder here.
- `~/.pi/agent/git/` (installed package clones, gitignored by pi)
- `~/.pi/*.{json,log}` (provider caches, logs, telemetry)

## Deploy

```sh
./.pi/link.sh
```

Backs up any pre-existing unowned files under `~/.pi/agent` (suffix
`.back.<ts>`) and stows `themes/`, `extensions/` via GNU stow. Idempotent —
safe to re-run. Does not touch settings, secrets, runtime state, or skills.
Requires `stow`.

## Notes

- `extensions/herdr-agent-state.ts` is owned by the herdr integration; herdr
  may overwrite it. Because `~/.pi/agent/extensions/` is a symlink here, any
  such update lands inside the repo and shows up in git.
- If you move the dotfiles checkout, re-run `link.sh` (stow adjusts the links).