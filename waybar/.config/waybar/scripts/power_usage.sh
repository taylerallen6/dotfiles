#!/bin/bash

BAT="/sys/class/power_supply/BAT0"

# Read state
if [ -f "$BAT/status" ]; then
    state=$(cat "$BAT/status")
else
    state=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | awk '/state:/ {print $2}')
fi

# Read power
watts=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | awk '/energy-rate:/ { printf "%.1f", $2 }')

# Output JSON for Waybar
if [[ "$state" == "Charging" || "$state" == "charging" ]]; then
    echo "{\"text\": \"${watts}\", \"class\": \"charging\"}"
else
    echo "{\"text\": \"${watts}\"}"
fi
