# Omarchy config bootstrap

This folder is split by responsibility:

- `install-hypr.sh`: links only Hypr config files into `~/.config/hypr`.
- `install-walker.sh`: links walker config into `~/.config/walker`.
- `bootstrap.sh`: orchestrates base setup and optional biometrics.
- `doctor.sh`: verifies links and biometric status.
- `../biometrics/setup-face-login.sh`: system-level face auth setup (opt-in).

## Usage

Run base setup (no root-level biometric changes):

```sh
./omarchy-config/bootstrap.sh
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
3. Optionally run `./omarchy-config/bootstrap.sh --with-biometrics`.
4. Run `./omarchy-config/doctor.sh`.
