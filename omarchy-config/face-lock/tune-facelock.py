#!/usr/bin/env python3
"""Set the Facelock keys that affect lock-screen latency, idempotently.

Run as root:  sudo python3 tune-facelock.py /etc/facelock/config.toml

Only the keys below are touched; everything else, comments included, is kept.
A timestamped backup is written next to the file before changing it.
"""

from __future__ import annotations

import os
import re
import shutil
import sys
import time

# A miss must free the camera sooner than the 5 s default: the lock already
# retries every 250 ms, so a long timeout only delays three attempts.
# The rate limit keeps that retry loop from disabling face for the rest of a
# minute while someone is actively trying to unlock.
SETTINGS: list[tuple[str, str, str]] = [
    ("recognition", "timeout_secs", "3"),
    ("security.rate_limit", "max_attempts", "20"),
    ("security.rate_limit", "window_secs", "60"),
]

SECTION_RE = re.compile(r"^\s*\[([^\]]+)\]\s*$")
KEY_RE = re.compile(r"^\s*#?\s*([A-Za-z0-9_-]+)\s*=")


def set_key(lines: list[str], section: str, key: str, value: str) -> list[str]:
    header = f"[{section}]"
    start = None
    for index, line in enumerate(lines):
        match = SECTION_RE.match(line)
        if match and match.group(1) == section:
            start = index
            break

    if start is None:
        if lines and lines[-1].strip():
            lines.append("")
        lines.append(header)
        lines.append(f"{key} = {value}")
        return lines

    end = len(lines)
    for index in range(start + 1, len(lines)):
        if SECTION_RE.match(lines[index]):
            end = index
            break

    for index in range(start + 1, end):
        match = KEY_RE.match(lines[index])
        if match and match.group(1) == key:
            lines[index] = f"{key} = {value}"
            return lines

    lines.insert(start + 1, f"{key} = {value}")
    return lines


def main() -> int:
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} <config.toml>", file=sys.stderr)
        return 2

    path = sys.argv[1]
    with open(path, encoding="utf-8") as handle:
        lines = handle.read().splitlines()

    original = list(lines)
    for section, key, value in SETTINGS:
        lines = set_key(lines, section, key, value)

    if lines == original:
        print(f"{path}: already tuned")
        return 0

    backup = f"{path}.back.{int(time.time())}"
    shutil.copy2(path, backup)
    temp = f"{path}.tmp"
    with open(temp, "w", encoding="utf-8") as handle:
        handle.write("\n".join(lines) + "\n")
    os.chmod(temp, 0o644)
    os.replace(temp, path)
    print(f"{path}: tuned (backup: {backup})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
