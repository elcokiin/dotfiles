# Face unlock for the Omarchy Quickshell lock screen

Facelock already handles `sudo` and polkit on this machine. This folder adds the
missing third consumer: the Quickshell lock (`omarchy.lock`).

## Why it did not work before

Omarchy's Quickshell lock does not reuse `/etc/pam.d/login`, `sudo`, or
`polkit-1`. It runs two dedicated PAM services:

| Lane | PAM service | Started by |
|---|---|---|
| Password | `/etc/pam.d/omarchy-lock-password` | Enter in the password field |
| Fingerprint | `/etc/pam.d/omarchy-lock-fingerprint` | Automatically once the lock is secure |

Facelock was only added to `sudo` and `polkit-1`, so the lock never asked it.
Adding `pam_facelock.so` to the password lane is not enough: that lane only
starts after a non-empty password is submitted, and a face miss would add its
whole timeout in front of every password attempt.

This integration adds a third, independent lane:

```
/etc/pam.d/omarchy-lock-face
  auth sufficient pam_facelock.so
  auth required   pam_deny.so
```

The password lane is untouched, so typing a password never waits for the
camera. A face miss has its own verdict and never consumes a password attempt
or increments `pam_faillock`.

## How the lock uses it

The patched lock plugin (`plugin/Service.qml`, `plugin/LockView.qml`) is a
clone of `omarchy.lock` with the face flow ported from Omarchy PR #6863:

- A face attempt starts on **deliberate activity** after the lock is secure:
  a keypress, a click, a pointer move that wakes a blanked display, or the lid
  reopening. Input that triggered the lock is ignored for 750 ms, so locking
  the screen and walking away does not immediately unlock it.
- One activity window runs up to **3 attempts**, 250 ms apart. A later key,
  click, or lid reopen starts a new window.
- A closed lid stops the camera; reopening it starts a fresh attempt.
- Face and password run in parallel PAM conversations. Either can unlock.
- The face icon brightens while the camera is scanning.

Because the plugin is a user clone, it survives `omarchy update`. The built-in
`omarchy.lock` is disabled automatically while the clone exists, and
`uninstall.sh` restores it.

## Install

```sh
./omarchy-config/face-lock/install.sh
```

The script:

1. Writes `/etc/pam.d/omarchy-lock-face`.
2. Tunes `/etc/facelock/config.toml` for lock latency (see below).
3. Restarts `facelock-daemon`.
4. Clones `omarchy.lock` to `~/.config/omarchy/plugins/$USER.lock` and applies
   the patch.
5. Verifies `omarchy-shell lock status` reports both a password and a face
   lane, and rolls back to the built-in lock if it does not.

Keep a terminal open the first time you lock the screen. A PAM mistake can
otherwise leave you with only a TTY. This installer writes a new PAM service,
it does not edit `sudo` or `polkit-1`, so privilege escalation stays intact.

## Test

```sh
omarchy-shell lock status | jq '{face, authenticating, lastEvent, lastEventAt}'
```

Then lock with `Super + Escape`, look at the camera, and press any key. The
`lastEvent` field should move through `face-attempt: 1` and end in `unlocked`.
If the face misses, type the password as usual.

## Latency tuning

`tune-facelock.py` changes only these keys and keeps a timestamped backup:

| Key | Default | Here | Why |
|---|---|---|---|
| `[recognition] timeout_secs` | 5 | 3 | A miss frees the camera sooner; a match is unaffected |
| `[security.rate_limit] max_attempts` | 5 | 20 | The lock retries; the default would disable face for the rest of the minute |
| `[security.rate_limit] window_secs` | 60 | 60 | Unchanged |

The daemon's persistent mode (default) is what makes a successful match fast:
models stay loaded and a match is roughly 200 ms after the camera has frames.
`camera_release_secs` (default 5 s) keeps the camera warm across the 250 ms
retries, so a retry does not pay the warm-up again.

If face is not reliable in your room, raise the threshold margin rather than
lowering security: run `facelock test` to see your match scores, then adjust
`[recognition] threshold` below the typical score. `min_auth_frames = 3` and
`require_ir = true` are liveness/anti-spoofing settings; leave them alone.

## Uninstall

```sh
./omarchy-config/face-lock/uninstall.sh
```

It removes the face PAM service, removes the clone, and re-enables the
built-in lock. The Facelock tuning is left in place; restore the newest
`/etc/facelock/config.toml.back.*` to revert it.

## After an Omarchy update

The clone is a copy of the 4.5.0 lock plugin (`plugin/base-version`). If an
update changes the lock, the clone keeps working but misses upstream fixes.
To re-port:

```sh
omarchy plugin remove "$USER.lock" --yes
omarchy plugin clone omarchy.lock
```

Then diff the new `Service.qml`/`LockView.qml` against this folder and apply
the face blocks, or run the installer with `--reclone --force` to try the
existing patch on the new base.

`doctor.sh` warns when the installed Omarchy version no longer matches
`plugin/base-version`.

## Files

| File | Purpose |
|---|---|
| `install.sh` | Idempotent installer with runtime check and rollback |
| `uninstall.sh` | Restores the built-in lock |
| `pam/omarchy-lock-face` | The face PAM service |
| `tune-facelock.py` | Idempotent Facelock tuning, backup included |
| `plugin/Service.qml` | Patched lock service (face PAM, retries, lid) |
| `plugin/LockView.qml` | Patched lock UI (face icon, activity signals) |
| `plugin/base-version` | Omarchy version this copy was ported against |
