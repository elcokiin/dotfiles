# Windows VM - Learnings

## Issues Found

### 1. Missing Polkit Agent

**Symptom:** `omarchy-windows-vm launch` fails silently with "Failed to start Windows VM!"

**Root Cause:** No polkit authentication agent installed. The VM script uses `pkexec` for privilege escalation, which requires a polkit agent to show the authorization dialog.

**Fix:** Install `hyprpolkitagent` and add to Hyprland autostart:
```bash
omarchy pkg add hyprpolkitagent
```

**Autostart entry** (in `~/.config/hypr/autostart.conf`):
```
exec-once = /usr/lib/hyprpolkitagent/hyprpolkitagent
```

### 2. Setgid Bit on ~/Windows Directory

**Symptom:** VM launch fails even with polkit agent installed.

**Root Cause:** The `~/Windows` directory had mode `2700` (setgid) instead of `700`. The VM script's `mounted_leaf_matches` security check requires exactly mode `700`.

**Fix:** Recreate the directory without setgid:
```bash
sudo umount /var/lib/omarchy/windows/mounts/users/1000/shared 2>/dev/null
rm -rf ~/Windows
mkdir -m 0700 ~/Windows
sudo mount --bind ~/Windows /var/lib/omarchy/windows/mounts/users/1000/shared
```

**Why this happens:** Some filesystems (btrfs) or tools may set the setgid bit on new directories. The bind mount inherits the source directory's permissions.

### 3. Directory Ownership

**Symptom:** "storage source must be a directory owned by uid XXXX"

**Root Cause:** `~/.windows` or `~/Windows` owned by root instead of the user.

**Fix:**
```bash
sudo chown $(id -u):$(id -g) ~/.windows ~/Windows
```

## Architecture Notes

- **Web interface (port 8006):** noVNC - meant for initial setup/monitoring only, poor quality
- **RDP (port 3389):** Full-quality remote desktop via `xfreerdp3`
- **Security:** Compose file is root-owned, user data in `~/.windows` and `~/Windows`
- **Mounts:** Bind mounts from user dirs to `/var/lib/omarchy/windows/mounts/users/<uid>/`

## Useful Commands

```bash
omarchy-windows-vm status      # Check VM status
omarchy-windows-vm launch      # Start and connect via RDP
omarchy-windows-vm launch -k   # Connect, keep running after RDP closes
omarchy-windows-vm stop        # Stop the VM
```

## Boot Behavior

After reboot:
- `hyprpolkitagent` starts automatically via Hyprland autostart
- Bind mounts are **NOT** persistent (lost on reboot)
- Running `omarchy-windows-vm launch` automatically recreates mounts via the privileged process
- No manual intervention needed - just run `launch` as usual

## For New PC Setup

1. Install omarchy-windows-vm dependencies: `omarchy pkg add hyprpolkitagent`
2. Run `omarchy-windows-vm install` (creates directories and compose file)
3. Run `setup-permissions.sh` to verify permissions
4. Test with `omarchy-windows-vm launch`
