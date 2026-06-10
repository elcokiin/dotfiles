#!/bin/zsh

LOW_BATTERY_LEVEL=12
BRIGHTNESS_STEP=2
BATTERY_PATH=$(find /sys/class/power_supply -maxdepth 1 -type l -name 'BAT*' | head -n 1)

if [ -z "$BATTERY_PATH" ]; then
	exit 0
fi

BATTERY_LEVEL=$(cat "$BATTERY_PATH/capacity")
BATTERY_STATUS=$(cat "$BATTERY_PATH/status")

if [ "$BATTERY_STATUS" = "Discharging" ] && [ "$BATTERY_LEVEL" -le "$LOW_BATTERY_LEVEL" ]; then
    notify-send -u critical "The battery is at: $BATTERY_LEVEL%. connect it soon"
		brightnessctl set $BRIGHTNESS_STEP%- || true
fi

if [ "$BATTERY_STATUS" = "Charging" ]; then
	dunstctl close-all
fi
