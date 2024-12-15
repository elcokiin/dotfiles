#!/bin/zsh

# /usr/local/bin/battery-monitor.sh

LOW_BATTERY_LEVEL=12
BRIGHTNESS_STEP=2
BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT1/capacity)
BATTERY_STATUS=$(cat /sys/class/power_supply/BAT1/status)

echo "$BATTERY_LEVEL" >> /home/elcokiin/hola

if [ "$BATTERY_STATUS" = "Discharging" ] && [ "$BATTERY_LEVEL" -le "$LOW_BATTERY_LEVEL" ]; then
    notify-send "The battery is at: $BATTERY_LEVEL%. connect it soon"
		sudo brightnessctl set $BRIGHTNESS_STEP%-
fi
