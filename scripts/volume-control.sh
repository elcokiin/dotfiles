#!/bin/bash

# ~/.local/bin/volume-control.sh

# Define step size
STEP=5

# Get default sink
SINK=$(pactl get-default-sink)

# Get current volume of sink (first channel)
VOLUME=$(pactl get-sink-volume "$SINK" | grep -oP '\d+(?=%)' | head -1)

if [[ $1 == "up" ]]; then
    NEW_VOL=$((VOLUME + STEP))
    [[ $NEW_VOL -gt 150 ]] && NEW_VOL=150
    pactl set-sink-volume "$SINK" "${NEW_VOL}%"
fi

if [[ $1 == "down" ]]; then
    NEW_VOL=$((VOLUME - STEP))
    [[ $NEW_VOL -lt 0 ]] && NEW_VOL=0
    pactl set-sink-volume "$SINK" "${NEW_VOL}%"
fi
