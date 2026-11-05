# Omarchy config links

This folder contains the customized Omarchy configs and a single script that
symlinks them all into place:

- `link.sh`: the one global link script. Symlinks `hypr/` (quattro-style `.lua`
  overrides: input, bindings, monitors, looknfeel, autostart), `fcitx5/`, `hooks/`,
  `omarchy/` (shell.json + extensions/omarchy-menu.jsonc), `proxy/`
  (`omarchy-proxy` + shell helpers), `.config/systemd/user/` (GOST relay
  service), `.config/herdr/` (config.toml),
  `.config/keyd/` (default.conf -> `/etc/keyd`), and `nvim/` (via stow) by
  default; `--with-tmux` also links `tmux-before-native/`, and
  `--with-biometrics` runs face-auth setup.
- `doctor.sh`: verifies links and biometric status.
- `delete-apps.sh`: helper to remove stock apps.
- `biometrics/setup-face-login.sh`: system-level face auth setup (opt-in).
- `biometrics/remove-face-login.sh`: removes the face-auth PAM integration.

Superseded by `link.sh` and removed: `bootstrap.sh`, `install-hypr.sh`,
`install-fcitx5.sh`, `install-hooks.sh`, `install-tmux.sh`, `install-nvim.sh`,
and `herdr/symlink.sh`. `walker/` and `hyprlock.conf` were moved to
`legacy/omarchy/` — walker is no longer used by Omarchy (replaced by
omarchy-menu, omacalc, and the omarchy.clipboard copy-history overlay) and the
lock is now the Quickshell `omarchy.lock` overlay.

## Windows VM (omarchy-windows-vm)

The `windows-vm/` folder contains fixes and documentation for common `omarchy-windows-vm` issues:

- `setup-permissions.sh`: Fixes ownership and permission issues on `~/.windows` and `~/Windows`
- `LEARNINGS.md`: Documents issues found (missing polkit agent, setgid bit, ownership)

**Quick fix after fresh install:**
```sh
./omarchy-config/windows-vm/setup-permissions.sh
```

## Proxy (system-wide toggle)

`proxy/omarchy-proxy` turns the corporate HTTP proxy on and off for
proxy-aware apps across the user session. GOST relays a local, unauthenticated
HTTP proxy at `127.0.0.1:8899` to the authenticated corporate proxy. This
allows Chromium-based apps and Spotify to use the proxy without handling the
corporate credentials themselves.

- writes GOST's credentials-bearing config to
  `~/.local/state/omarchy/proxy/gost.json` (mode 600, private directory) and
  starts the user service `.config/systemd/user/omarchy-proxy-gost.service`,
  which only listens on loopback. The service is enabled after first use, but
  only runs when the private config exists (removed when the proxy is off);
- verifies a real HTTPS request through GOST before publishing proxy settings;
- writes `~/.config/environment.d/90-omarchy-proxy.conf` and updates the
  systemd user environment (`systemctl --user set-environment`) with only the
  local, credential-free proxy URL, so new apps inherit `http_proxy`,
  `https_proxy`, `all_proxy` and their uppercase variants;
- pushes the same variables to the D-Bus activation environment;
- sets the GNOME/GIO proxy (`gsettings org.gnome.system.proxy`), which GTK
  apps, Firefox/Zen and Chromium-family browsers read;
- updates `git` and `npm`;
- configures Spotify's own proxy preferences to use the local relay, since the
  Linux client does not consistently use the desktop proxy. The helper writes
  prefs without corporate credentials; Spotify must be restarted after
  toggling;
- configures Chromium's `~/.config/chromium-flags.conf` to use the local relay,
  because Chromium in this Hyprland session does not honor GSettings by itself;
  Chromium must be restarted after toggling;
- writes `~/.config/omarchy/proxy/env.sh`, which `proxy/shell.sh` sources from
  `~/.bashrc`, so every new terminal has the variables immediately.

Corporate credentials stay in `~/.proxy_env_aliadas` (mode 600) and the private
GOST config while enabled. New proxy settings do not copy them into app
preferences, environment files, Git/npm config, status output, or process
arguments. Generated shell and `environment.d` files contain only
`127.0.0.1:8899`, are mode 600, and are not tracked by git. Processes that were
already running can retain their old environment until they are restarted.

Commands:

```sh
omarchy-proxy on          # enable
omarchy-proxy off         # disable
omarchy-proxy toggle      # switch
omarchy-proxy status      # human-readable state
omarchy-proxy test        # curl through the proxy
omarchy-proxy active      # exit 0 when enabled (used by the menu checkmark)
omarchy-proxy bar-status  # Waybar-style JSON for the bar widget
omarchy-proxy ui          # toggle in a terminal, showing each step
```

In shells, the old helpers still work: `proxyon`, `proxyoff`, `proxytoggle`,
`proxystatus`, `proxytest`.

The proxy is exposed in two places:

- **Omarchy menu** (`omarchy/extensions/omarchy-menu.jsonc`): root `Proxy`
  submenu (toggle with ✓, status, test, edit credentials) and
  `Trigger → Toggle → Proxy`.
- **Bar** (`omarchy/shell.json`): a `proxy` command widget after
  `omarchy.network`; the shield icon is accented when the proxy is active.
  A click opens a terminal (`omarchy-launch-tui … omarchy-proxy ui`) that
  shows each step and the command behind it, then waits for Enter with a
  final “todo quedó configurado / ya puedes cerrar” message.

Already-running applications may need a restart to pick up the change. This
is still an HTTP proxy, not a transparent VPN: apps that ignore proxy settings,
non-HTTP traffic, root/system services, and many UDP flows are not forced
through it. Any local process can use the loopback relay while it is enabled.

## Non-Omarchy configs used here

These are not Omarchy configs, so they live at the repo root (see
`AGENTS.md`), but they are active on this setup:

- `.config/systemd/user/omarchy-proxy-gost.service` — user service for the
  authenticated upstream relay, linked by `omarchy-config/link.sh` and enabled
  only while the proxy toggle is on.
- `.config/herdr/` — Herdr terminal-multiplexer config, linked by `link.sh`.
- `.config/keyd/` — keyd input remapping (`default.conf`). keyd talks directly
  with the kernel, so the config must live in `/etc/keyd`, not `~/.config`.
  `link.sh` links it there by default: it opens a terminal in the foreground
  running `.config/keyd/install.sh`, which auto-elevates with sudo, links the
  config, and enables the keyd daemon.
- `../scripts/hash-renamer.sh` — renames marker files. A file named
  `##name##rest.ext` (the `##` markers are how you "request" a rename) becomes
  `name-v#-dd-mm-yyyy-rest.ext` in the same folder; `v#` counts the files
  already named `name-v[0-9]*` there, so `##hola##pero.txt` next to
  `hola-v1-...` and `hola-v2-...` becomes `hola-v3-<today>-pero.txt`. Only
  names starting with `##` are considered; `##` names without the second `##`
  are left alone. Content is never touched. It runs as a daemon started by
  `hypr/autostart.lua` (`hash-renamer.sh --watch`, rescans every 10s), or
  manually: `./scripts/hash-renamer.sh` (one pass, `--dry-run` to preview,
  `--help` for options).

## Usage

Run the full link setup (everything except opt-in modules):

```sh
./omarchy-config/link.sh
```

Add optional modules:

```sh
./omarchy-config/link.sh --with-tmux --with-biometrics
```

Biometrics (opt-in):

```sh
HOWDY_DEVICE_PATH=/dev/v4l/by-id/your-ir-camera ./omarchy-config/link.sh --with-biometrics
```

If `HOWDY_DEVICE_PATH` is not set, camera selection is interactive.
The setup shows only usable video-capture devices, prefers stable `/dev/v4l/by-id`
or `/dev/v4l/by-path` paths, and marks the likely IR camera as recommended.
In that selection menu, press `p` to preview the recommended camera or `p1`,
`p2`, etc. to preview a specific option before selecting it.
During face enrollment, the setup asks for the model label before opening the
camera. Then it prompts before each capture: press `p` to preview the selected
camera, close the preview window, then press `Enter` to let Howdy capture that
model immediately without another label prompt. Use
`HOWDY_ENROLL_PREVIEW=always` to open the preview before every capture
automatically, or `HOWDY_ENROLL_PREVIEW=never` to skip those prompts.

The biometric setup tunes Howdy for faster local authentication by default:

```sh
HOWDY_PROFILE=fast HOWDY_ENROLL_COUNT=3 ./omarchy-config/link.sh --with-biometrics
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
  ./omarchy-config/link.sh --with-biometrics
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
HOWDY_RUN_TEST=1 ./omarchy-config/link.sh --with-biometrics
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
2. Run `./omarchy-config/link.sh`.
3. Optionally run `./omarchy-config/link.sh --with-tmux`.
4. Optionally run `./omarchy-config/link.sh --with-biometrics`.
5. Run `./omarchy-config/doctor.sh`.
