# Legacy X11 Dotfiles

This directory contains the old X11/bspwm setup. It is intentionally separated from the Omarchy setup so it can be tested later without being confused with the active desktop.

## Contents

- `config/`: legacy `~/.config` folders for bspwm, sxhkd, rofi, dunst, kitty, picom, GTK, and the old Neovim config.
- `scripts/`: helper scripts used by sxhkd and rofi.
- `systemd/`: user-level battery monitor service and timer.
- `assets/`: wallpapers and icons used by the legacy config.
- `home/`: home-level files used by the legacy session.
- `install.sh`: portable installer for the current user.

## Install

```sh
./legacy/x11/install.sh
```

Enable the battery monitor timer:

```sh
./legacy/x11/install.sh --with-user-systemd
```

The installer generates `~/.env` from `home/.env.example`, links config folders into `~/.config`, links scripts into `~/.local/bin`, and regenerates `.template` files when `envsubst` is available.

## Notes

This setup is not the active path. Keep fixes here limited to portability, obvious broken links, and making the old desktop easy to launch for testing.
