#!/usr/bin/env bash

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"
win_width='88px'
list_col='1'
list_row='6'

# Volume Info 
# Get the volume of the default audio sink
output_volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
# Extract the decimal number, split by the dot, and get the last value
mesg_volume=$(echo "$output_volume" | awk -F '[. ]' '/Volume:/ {print $NF}')

if [[ "$mesg_volume" == "[MUTED]" ]]; then
    mesg_volume="Muted"
else
   if [[ "$mesg_volume" == "00" ]]; then
       mesg_volume="100%"
   else
       mesg_volume="$mesg_volume%"
    fi
fi 

# Battery Info
percentage_battery="`acpi -b | cut -d',' -f2 | tr -d ' ',\%`"
status_battery="`acpi -b | cut -d',' -f1 | cut -d':' -f2 | tr -d ' '`"

# Charging Status
if [[ $status_battery = *"Charging"* ]]; then
    ICON_CHRG=""
elif [[ $status_battery = *"Full"* ]]; then
    ICON_CHRG=""
else
    ICON_CHRG=""
fi

# Discharging
if [[ $percentage_battery -ge 5 ]] && [[ $percentage_battery -le 19 ]]; then
    ICON_DISCHRG=""
elif [[ $percentage_battery -ge 20 ]] && [[ $percentage_battery -le 39 ]]; then
    ICON_DISCHRG=""
elif [[ $percentage_battery -ge 40 ]] && [[ $percentage_battery -le 59 ]]; then
    ICON_DISCHRG=""
elif [[ $percentage_battery -ge 60 ]] && [[ $percentage_battery -le 79 ]]; then
    ICON_DISCHRG=""
elif [[ $percentage_battery -ge 80 ]] && [[ $percentage_battery -le 100 ]]; then
    ICON_DISCHRG=""
fi

# Brightness Info
backlight="$(printf "%.0f\n" `light -G`)"
ICON_BRIGHT=""

# Wifi Info
if [[ "$(nmcli radio wifi)" == "enabled" ]]; then
    [ -n "$active" ] && active+=",3" || active="-a 3"
    ICON_WIFI=""
else
    [ -n "$urgent" ] && urgent+=",3" || urgent="-u 3"
    ICON_WIFI=""
fi

# Date Info
date=$(date +"%A, %B %d %Y")
time=$(date +"%I:%M %p")
ICON_DATE="ⵚ"

# Microphone Info
amixer get Capture | grep '\[on\]' &>/dev/null
if [[ "$?" == 0 ]]; then
    [ -n "$active" ] && active+=",5" || active="-a 5"
	micon=''
else
    [ -n "$urgent" ] && urgent+=",5" || urgent="-u 5"
	micon=''
fi

# Options
option_1="$ICON_CHRG"
if [[ "$mesg_volume" == "Muted" ]]; then
    option_2=""
else
    option_2=""
fi

option_3="$ICON_BRIGHT"
option_4="$ICON_WIFI"
option_5="$ICON_DATE"
option_6="$micon"

# Rofi CMD
rofi_cmd() {
	rofi -theme-str "window {width: $win_width;}" \
		-theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str "textbox-prompt-colon {str: \"$ICON_DISCHRG\";}" \
		-dmenu \
		${active} ${urgent} \
		-markup-rows \
		-theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6" | rofi_cmd
}

# Execute command
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		notify-send -i "/" "${ICON_DISCHRG} Remaining: ${percentage_battery}%"
	elif [[ "$1" == '--opt2' ]]; then
		notify-send -i "/" "$option_2 Volume: ${mesg_volume}"
    elif [[ "$1" == '--opt3' ]]; then
        notify-send -i "/" "$option_3 Brightness: ${backlight}%"
    elif [[ "$1" == '--opt4' ]]; then
        nm-connection-editor
    elif [[ "$1" == '--opt5' ]]; then
        notify-send -i "/home/elcokiin/Images/icons/calendar.png" "$time" "$date"
    elif [[ "$1" == '--opt6' ]]; then
        amixer set Capture toggle
    fi
}

chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
		run_cmd --opt1
        ;;
    $option_2)
		run_cmd --opt2
        ;;
    $option_3)
        run_cmd --opt3
        ;;
    $option_4)
        run_cmd --opt4
        ;;
    $option_5)
        run_cmd --opt5
        ;;
    $option_6)
        run_cmd --opt6
        ;;
esac