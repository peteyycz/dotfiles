#!/bin/bash

while true; do
    time=$(date '+%H:%M %p')
    cpu=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print int(usage) "%"}')
    vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1)
    wifi=$(nmcli -t -f active,ssid dev wifi | egrep '^yes' | cut -d':' -f2)
    bluetooth_headphone=$(~/.config/sway/bluetooth.sh)

    echo "$wifi | $bluetooth_headphone | CPU: $cpu | Vol: $vol | $time"
    sleep 1
done
