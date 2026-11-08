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
  `--with-biometrics` runs the legacy Howdy setup (not used by the Quickshell
  lock; use `face-lock/install.sh` instead).
- `doctor.sh`: verifies links and biometric status.
- `delete-apps.sh`: helper to remove stock apps.
- `face-lock/`: Facelock + Quickshell lock screen integration (the face setup
  currently used on this machine).
- `biometrics/setup-face-login.sh`: legacy Howdy setup for hyprlock (opt-in).
- `biometrics/remove-face-login.sh`: removes the legacy Howdy PAM integration.

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

Add the optional tmux module:

```sh
./omarchy-config/link.sh --with-tmux
```

## Face unlock (Facelock + Quickshell lock)

This machine uses **Facelock**, not Howdy, and the lock is the Quickshell
`omarchy.lock`, not hyprlock. `face-lock/` connects Facelock to that lock:

- `/etc/pam.d/sudo` and `/etc/pam.d/polkit-1` carry `pam_facelock.so` (already
  configured by `facelock setup`).
- `/etc/pam.d/omarchy-lock-face` is a third, independent lane for the lock
  screen, so a face miss never delays a typed password.
- A cloned `omarchy.lock` plugin starts a face attempt on a keypress, click,
  pointer move that wakes a blanked display, or lid reopen. It retries up to
  three times per activity window and falls back to the password untouched.

Install:

```sh
./omarchy-config/face-lock/install.sh
```

Test:

```sh
omarchy-shell lock status | jq '{face, authenticating, lastEvent}'
```

Then lock with `Super + Escape`, look at the camera, and press any key. Details,
tuning, rollback, and post-update re-porting are in `face-lock/README.md`.

The old `biometrics/` Howdy scripts target hyprlock, which Omarchy no longer
uses. They are kept for history; do not run `link.sh --with-biometrics` on this
setup, because it would add Howdy to a lock that is not in use.

## Validation

```sh
./omarchy-config/doctor.sh
```

This checks symlinks, the proxy, and the current biometric setup:

- Facelock daemon, enrollment, and IR requirement.
- `pam_facelock` in `sudo`, `polkit-1`, and `omarchy-lock-face`.
- The patched `$USER.lock` plugin and the Quickshell lock's face lane.

## Replication on another PC

1. Clone this repository.
2. Run `./omarchy-config/link.sh`.
3. Optionally run `./omarchy-config/link.sh --with-tmux`.
4. On a machine with an IR camera and Facelock enrolled, run
   `./omarchy-config/face-lock/install.sh`.
5. Run `./omarchy-config/doctor.sh`.
