#!/bin/sh

current="$(fcitx5-remote -n 2>/dev/null || true)"

case "$current" in
  keyboard-es)
    fcitx5-remote -s keyboard-us
    ;;
  *)
    fcitx5-remote -s keyboard-es
    ;;
esac
