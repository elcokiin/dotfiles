# Architecture Refactor: Omarchy Primary

Date: 2026-06-10

## Goal

Make Omarchy the primary dotfiles path and keep the previous X11/bspwm setup as a runnable legacy profile.

The repository now has two explicit areas:

- `omarchy-config/`: active Omarchy/Hyprland setup.
- `legacy/x11/`: archived but runnable X11/bspwm setup.

## New Structure

```text
.
├── omarchy-config/
│   ├── bootstrap.sh
│   ├── install-hypr.sh
│   ├── install-walker.sh
│   ├── install-fcitx5.sh
│   ├── install-nvim.sh
│   ├── install-tmux.sh
│   ├── biometrics/
│   ├── hypr/
│   ├── walker/
│   ├── fcitx5/
│   ├── nvim/
│   └── tmux-before-native/
├── legacy/x11/
│   ├── install.sh
│   ├── config/
│   ├── scripts/
│   ├── systemd/
│   ├── assets/
│   └── home/
└── docs/
    └── ARCHITECTURE_REFACTOR.md
```

## What Changed

- Moved the old X11 stack into `legacy/x11/`:
  - `config/`
  - `scripts/`
  - `systemd/`
  - `assets/`
  - old home files: `.env.example`, `.zshrc`, `.zsh_aliases`, `.gitconfig`
- Moved biometric scripts into `omarchy-config/biometrics/` so the primary setup is self-contained.
- Added root `README.md` to make Omarchy the documented default.
- Added `legacy/x11/README.md` for future testing of the old setup.
- Replaced the old legacy installer with a portable user-level installer.
- Added `omarchy-config/install-tmux.sh`.
- Updated `omarchy-config/bootstrap.sh` with explicit optional modules:
  - `--with-nvim`
  - `--with-tmux`
  - `--with-biometrics`

## Primary Omarchy Flow

Base setup:

```sh
./omarchy-config/bootstrap.sh
```

Optional editor and tmux setup:

```sh
./omarchy-config/bootstrap.sh --with-nvim --with-tmux
```

Optional face login setup:

```sh
HOWDY_DEVICE_PATH=/dev/v4l/by-id/your-ir-camera ./omarchy-config/bootstrap.sh --with-biometrics
```

Validation:

```sh
./omarchy-config/doctor.sh
```

## Legacy X11 Flow

Install the old bspwm/X11 setup for the current user:

```sh
./legacy/x11/install.sh
```

Install and enable the legacy battery monitor as a user timer:

```sh
./legacy/x11/install.sh --with-user-systemd
```

The new legacy installer:

- Computes paths from its own location.
- Avoids hardcoded `/home/elcokiin` paths.
- Links configs into `~/.config`.
- Links scripts into `~/.local/bin`.
- Generates `~/.env` from `legacy/x11/home/.env.example`.
- Regenerates `.template` files with `envsubst` when available.
- Uses user-level systemd for the battery monitor.

## Critical Legacy Fixes

- `legacy/x11/install.sh` no longer requires running the whole install as root.
- `legacy/x11/systemd/battery-monitor.service` no longer hardcodes `User=elcokiin` or `/usr/local/bin`.
- `legacy/x11/scripts/battery-monitor.sh` detects `BAT*` dynamically instead of assuming `BAT1`.
- `legacy/x11/scripts/powermenu-rofi.sh` now maps logout to an implemented action.
- `legacy/x11/scripts/settings-rofi.sh` no longer points to `/home/elcokiin/Images/icons/calendar.png`.
- `legacy/x11/home/.env.example` now uses generated placeholders for the current home and legacy directory.

## Remaining Known Issues

- The legacy GTK theme references many `../assets/*` files that are not present in this repository. This was pre-existing and may affect GTK theme completeness.
- The legacy scripts still depend on old X11 tools such as `bspwm`, `sxhkd`, `rofi`, `maim`, `xclip`, `xdotool`, `light`, `acpi`, and `dunst`.
- `omarchy-config/nvim/lua/plugins/theme.lua` is a symlink to the active Omarchy theme path. That is useful on the current machine but not portable to systems without Omarchy's current theme symlink.
- `omarchy-config/delete-apps.sh` remains a manual maintenance script. It is intentionally not connected to bootstrap because it removes packages and config directories.

## Direction

Future changes should default to `omarchy-config/`. Changes under `legacy/x11/` should be limited to keeping the old environment testable, not evolving it as the main desktop.
