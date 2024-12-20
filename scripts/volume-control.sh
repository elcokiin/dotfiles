#!/bin/bash

# ~/.local/bin/volume-control.sh

# Get current volume
current_volume=$(amixer get Master | grep -oP '\[\K[0-9]+(?=%\])')

# increase volume
if [[ $1 == "up" ]]; then
    new_percentage=$((current_volume + 5))
    if ((new_percentage < 120)); then
			amixer -Mq set Master,0 5%+ unmute
    fi
fi

# decrease volume
if [[ $1 == "down" ]]; then
    new_percentage=$((current_volume - 5))
    if ((new_percentage > 0)); then
			amixer -Mq set Master,0 5%- unmute
    fi
fi
