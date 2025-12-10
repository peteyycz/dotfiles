#!/bin/bash
vpn=$(nmcli -t -f NAME,TYPE connection show --active | grep vpn | cut -d: -f1)
if [ -n "$vpn" ]; then
    echo "{\"text\": \"$vpn\", \"class\": \"connected\", \"tooltip\": \"Connected to $vpn\"}"
else
    echo "{\"text\": \"VPN\", \"class\": \"disconnected\", \"tooltip\": \"Not connected\"}"
fi
