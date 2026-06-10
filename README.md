# Dotfiles

This repository is organized around Omarchy as the primary desktop setup.

## Primary: Omarchy

Use `omarchy-config/` for the active system:

```sh
./omarchy-config/bootstrap.sh
```

Optional modules are explicit:

```sh
./omarchy-config/bootstrap.sh --with-nvim --with-tmux
HOWDY_DEVICE_PATH=/dev/v4l/by-id/your-ir-camera ./omarchy-config/bootstrap.sh --with-biometrics
./omarchy-config/doctor.sh
```

## Legacy: X11/bspwm

The previous X11 setup lives under `legacy/x11/`. It is kept runnable for future testing, but it is not the default path.

```sh
./legacy/x11/install.sh
./legacy/x11/install.sh --with-user-systemd
```

See `docs/ARCHITECTURE_REFACTOR.md` for the reorganization notes and rationale.
