#!/bin/bash

connected_devices=$(bluetoothctl devices Connected 2>/dev/null)

if [ -z "$connected_devices" ]; then
    echo ""
    exit
fi

while IFS= read -r line; do
    if [ -n "$line" ]; then
        mac_address=$(echo "$line" | awk '{print $2}')
        device_info=$(bluetoothctl info "$mac_address" 2>/dev/null)
        
        if echo "$device_info" | grep -q "Audio\|Headset\|Headphones\|A2DP\|HFP"; then
            device_name=$(echo "$line" | cut -d' ' -f3- | cut -c1-15)
            echo "🎧 $device_name"
            exit
        fi
    fi
done <<< "$connected_devices"

echo ""
