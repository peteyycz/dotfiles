#!/bin/bash

# Loop through each device in your list and connect
while read -r device; do
    if [[ -n "$device" ]]; then
        bluetoothctl connect "$device"
    fi
done < "$HOME/.bl-devices"
