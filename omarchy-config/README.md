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
The setup shows only usable video-capture devices, prefers stable `/dev/v4l/by-id`
or `/dev/v4l/by-path` paths, and marks the likely IR camera as recommended.
In that selection menu, press `p` to preview the recommended camera or `p1`,
`p2`, etc. to preview a specific option before selecting it.
During face enrollment, the setup also prompts before each capture: press `p`
to preview the selected camera, close the preview window, then press `Enter` to
let Howdy capture that model. Use `HOWDY_ENROLL_PREVIEW=always` to open the
preview before every capture automatically, or `HOWDY_ENROLL_PREVIEW=never` to
skip those prompts.

The biometric setup tunes Howdy for faster local authentication by default:

```sh
HOWDY_PROFILE=fast HOWDY_ENROLL_COUNT=3 ./omarchy-config/bootstrap.sh --with-biometrics
```

Profiles:

- `fast`: default. Uses the HOG detector, short timeout, MJPEG, 15 FPS, and a more tolerant match threshold.
- `balanced`: close to Howdy defaults.
- `secure`: stricter threshold; expect more password fallbacks.
- `cnn`: more tolerant of pose/angle changes, but slower without a GPU.

For best results, enroll several models in normal real-world conditions: straight at the camera, slight left/right angle, with and without glasses, and both day/night lighting. More models usually reduce false negatives better than a single "perfect" photo.

Advanced overrides are available as env vars:

```sh
HOWDY_CERTAINTY=4.5 HOWDY_TIMEOUT=2 HOWDY_MAX_HEIGHT=320 HOWDY_ENROLL_COUNT=4 \
  ./omarchy-config/bootstrap.sh --with-biometrics
```

Howdy's `certainty` is a threshold from 1 to 10 where higher is more tolerant; values above 5 are not recommended because they increase false-positive risk.

After setup, test the real PAM integration with:

```sh
sudo -k && sudo -v
```

Then test the lock screen with `Super + Escape`. Howdy also has a graphical
`howdy test` window, but the setup skips it by default because Qt/X11 display
access often fails under `sudo` on Wayland even when face authentication is
configured correctly. To run it anyway:

```sh
HOWDY_RUN_TEST=1 ./omarchy-config/bootstrap.sh --with-biometrics
```

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
