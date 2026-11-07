# Dotfiles

This repository is organized around Omarchy as the primary desktop setup.

## Primary: Omarchy

Use `omarchy-config/` for the active system:

```sh
./omarchy-config/link.sh
```

Optional modules are explicit:

```sh
./omarchy-config/link.sh --with-tmux
HOWDY_DEVICE_PATH=/dev/v4l/by-id/your-ir-camera ./omarchy-config/link.sh --with-biometrics
./omarchy-config/doctor.sh
```

## System-level modules

Non-Omarchy tools (or configs that need root) live in the repo root, not in
`omarchy-config/`, but are documented there since they run on Omarchy:

- `.config/keyd/` — system-wide input remapping. AltGr is claimed by keyd as a
  private layer (`special`) at the evdev level, below Wayland, so Hyprland never
  sees `Alt_R` and a future Omarchy update cannot steal it. AltGr + HJKL ->
  arrows, AltGr + Q..P -> digits 1..0, AltGr + g / Shift+g -> Home / End,
  AltGr + `[`/`]` -> PageUp/PageDown, AltGr + `-`/`=` -> brightness,
  AltGr + `;`/`'` -> volume, AltGr + Tab -> Esc. Left Alt + Right Alt -> F13 for
  dictation push-to-talk. The number row types normal digits.
  Install with `sudo ./.config/keyd/install.sh`; apply changes with
  `sudo keyd reload`.
- `.config/herdr/` — herdr terminal multiplexer config; linked by `link.sh`.

## Legacy: X11/bspwm

The previous X11 setup lives under `legacy/x11/`. It is kept runnable for future testing, but it is not the default path.

```sh
./legacy/x11/install.sh
./legacy/x11/install.sh --with-user-systemd
```

See `docs/ARCHITECTURE_REFACTOR.md` for the reorganization notes and rationale.
