#!/usr/bin/env python3

import json
import os
import re
import stat
import sys
import tempfile
from pathlib import Path


KEYS = {
    "network.proxy.mode",
    "network.proxy.addr",
    "network.proxy.user",
    "network.proxy.pass",
}


def quote(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def main() -> int:
    if len(sys.argv) != 2 or sys.argv[1] not in {"on", "off"}:
        print("usage: spotify-prefs.py on|off", file=sys.stderr)
        return 2

    prefs = Path(os.environ.get("OMARCHY_SPOTIFY_PREFS") or "~/.config/spotify/prefs").expanduser()
    enabled = sys.argv[1] == "on"

    if not enabled and not prefs.exists():
        return 0

    existing = prefs.read_text() if prefs.exists() else ""
    kept = [
        line
        for line in existing.splitlines()
        if not any(re.match(rf"^\s*{re.escape(key)}\s*=", line) for key in KEYS)
    ]

    if enabled:
        port = os.environ["OMARCHY_PROXY_PORT"]
        kept.extend(
            [
                "network.proxy.mode=2",
                f"network.proxy.addr={quote(f'127.0.0.1:{port}@http')}",
            ]
        )
    else:
        kept.append("network.proxy.mode=1")

    contents = "\n".join(kept).rstrip() + "\n"
    prefs.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=".prefs.", dir=prefs.parent, text=True)
    try:
        with os.fdopen(fd, "w") as output:
            output.write(contents)
            output.flush()
            os.fsync(output.fileno())
        os.chmod(temporary, stat.S_IRUSR | stat.S_IWUSR)
        os.replace(temporary, prefs)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)

    print(f"Spotify proxy {'configured' if enabled else 'cleared'}; restart Spotify to apply.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (KeyError, OSError) as error:
        print(f"spotify-prefs: {error}", file=sys.stderr)
        raise SystemExit(1)
