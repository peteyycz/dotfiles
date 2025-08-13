#!/bin/sh
geom=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
grim -g "$geom" - | wl-copy --type image/png
