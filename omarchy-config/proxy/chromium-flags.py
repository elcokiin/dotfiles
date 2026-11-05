#!/usr/bin/env python3

import os
import stat
import sys
import tempfile
from pathlib import Path


BEGIN = "# BEGIN omarchy-proxy"
END = "# END omarchy-proxy"


def main() -> int:
    if len(sys.argv) != 2 or sys.argv[1] not in {"on", "off"}:
        print("usage: chromium-flags.py on|off", file=sys.stderr)
        return 2

    config_home = Path(os.environ.get("XDG_CONFIG_HOME") or "~/.config").expanduser()
    flags_file = config_home / "chromium-flags.conf"
    proxy_url = f"http://127.0.0.1:{os.environ.get('OMARCHY_PROXY_PORT', '8899')}"

    original = flags_file.read_text().splitlines() if flags_file.exists() else []
    lines: list[str] = []
    skipping = False
    for line in original:
        if line == BEGIN:
            skipping = True
            continue
        if skipping:
            if line == END:
                skipping = False
            continue
        lines.append(line)

    if skipping:
        raise ValueError(f"unterminated managed block in {flags_file}")

    if sys.argv[1] == "on":
        if lines and lines[-1] != "":
            lines.append("")
        lines.extend(
            [
                BEGIN,
                f"--proxy-server={proxy_url}",
                "--proxy-bypass-list=localhost;127.0.0.0/8;[::1];10.0.0.0/8;192.168.0.0/16;*.local",
                END,
            ]
        )

    while lines and lines[-1] == "":
        lines.pop()
    contents = "\n".join(lines) + ("\n" if lines else "")

    if not contents:
        flags_file.unlink(missing_ok=True)
        return 0

    config_home.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=".chromium-flags.", dir=config_home, text=True)
    try:
        with os.fdopen(fd, "w") as output:
            output.write(contents)
            output.flush()
            os.fsync(output.fileno())
        os.chmod(temporary, stat.S_IRUSR | stat.S_IWUSR)
        os.replace(temporary, flags_file)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except OSError as error:
        print(f"chromium-flags: {error}", file=sys.stderr)
        raise SystemExit(1)
