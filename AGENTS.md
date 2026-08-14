# Repository conventions

## Where configs live

- Anything that is not explicitly Omarchy, or does not ship built-in with
  Omarchy, must NOT be placed directly inside the `omarchy-config/` folder.
- Instead, keep it at the repo root in its own folder (e.g. `keyd/`, `herdr/`).
- If the tool is actually used on this Omarchy setup, document that in
  `omarchy-config/README.md`: note that it is used, where it lives, and how to
  install/enable it. Do not drop the files into `omarchy-config/` itself.
- `omarchy-config/` is reserved for configs deployed by `omarchy-config/link.sh`
  into `~/.config` (plus its opt-in modules and helpers).

## Custom modifications workflow

**NEVER modify system files directly.** Any change to `~/.config`, `~/.local`, or
anywhere else on the Linux system must follow this process:

1. Create or update the files first inside the dotfiles repo (e.g. in
   `omarchy-config/` or the tool's own folder at the repo root).
2. Write a script or set up symlinks to deploy those files to their target
   locations.
3. **Ask the user for confirmation** before applying the real implementation
   (running the script, creating the symlinks, or copying files into place).