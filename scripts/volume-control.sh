#!/bin/bash

current_volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')

current_percentage=$(awk "BEGIN {print $current_volume * 100}")

# increase volume
if [[ $1 == "up" ]]; then
	new_percentage=$(awk "BEGIN {print $current_percentage + 10}")
	if (( $(echo "$new_percentage > 120" | bc -l) )); then
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 120%
    else
        wpctl set-volume @DEFAULT_AUDIO_SINK@ $new_percentage%
    fi
fi

# dincrease volume
if [[ $1 == "down" ]]; then
	new_percentage=$(awk "BEGIN {print $current_percentage - 10}")
	if (( $(echo "$new_percentage < 0" | bc -l) )); then
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%
    else
        wpctl set-volume @DEFAULT_AUDIO_SINK@ $new_percentage%
    fi
fi
