# Omarchy config bootstrap

This folder is split by responsibility:

- `install-hypr.sh`: links only Hypr config files into `~/.config/hypr`.
- `install-walker.sh`: links walker config into `~/.config/walker`.
- `install-fcitx5.sh`: links Fcitx5 keyboard/input-method config.
- `install-nvim.sh`: optionally links the Omarchy LazyVim config.
- `install-tmux.sh`: optionally links the Omarchy tmux config.
- `bootstrap.sh`: orchestrates base setup and optional modules.
- `doctor.sh`: verifies links and biometric status.
- `biometrics/setup-face-login.sh`: system-level face auth setup (opt-in).
- `biometrics/remove-face-login.sh`: removes the face-auth PAM integration.

## Usage

Run base setup (no root-level biometric changes):

```sh
./omarchy-config/bootstrap.sh
```

Run base setup with optional editor/tmux config:

```sh
./omarchy-config/bootstrap.sh --with-nvim --with-tmux
```

Run base setup + biometrics (opt-in):

```sh
HOWDY_DEVICE_PATH=/dev/v4l/by-id/your-ir-camera ./omarchy-config/bootstrap.sh --with-biometrics
```

If `HOWDY_DEVICE_PATH` is not set, camera selection is interactive.

## Validation

```sh
./omarchy-config/doctor.sh
```

This checks:

- Symlinks for Hypr and Walker.
- Whether `hyprlock.conf` is linked from dotfiles.
- PAM Howdy lines in `/etc/pam.d/{hyprlock,sudo,polkit-1}`.
- Hyprlock biometric UI setting.

## Replication on another PC

1. Clone this repository.
2. Run `./omarchy-config/bootstrap.sh`.
3. Optionally run `./omarchy-config/bootstrap.sh --with-nvim --with-tmux`.
4. Optionally run `./omarchy-config/bootstrap.sh --with-biometrics`.
5. Run `./omarchy-config/doctor.sh`.
