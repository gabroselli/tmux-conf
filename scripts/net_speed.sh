#!/usr/bin/env bash

IFACE="en0"
INTERVAL=5
DOWN_FILE="/tmp/tmux_net_down"
UP_FILE="/tmp/tmux_net_up"

format_speed() {
    local bytes=$1
    if (( bytes >= 1048576 )); then
        awk "BEGIN { printf \"%.1f MB/s\", $bytes / 1048576 }"
    elif (( bytes >= 1024 )); then
        printf "%d KB/s" $(( bytes / 1024 ))
    else
        printf "%d B/s" "$bytes"
    fi
}

read -r new_down new_up < <(netstat -ibn | awk -v iface="$IFACE" '$1 == iface && $3 ~ /Link/ { print $7, $10 }')
new_down=${new_down:-0}
new_up=${new_up:-0}

old_down=$(cat "$DOWN_FILE" 2>/dev/null || echo 0)
old_up=$(cat "$UP_FILE" 2>/dev/null || echo 0)

echo "$new_down" > "$DOWN_FILE"
echo "$new_up" > "$UP_FILE"

delta_down=$(( (new_down - old_down) / INTERVAL ))
delta_up=$(( (new_up - old_up) / INTERVAL ))
(( delta_down < 0 )) && delta_down=0
(( delta_up < 0 )) && delta_up=0

printf "#[fg=#81c8be]↓%s  #[fg=#ef9f76]↑%s" "$(format_speed "$delta_down")" "$(format_speed "$delta_up")"
