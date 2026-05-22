#!/usr/bin/env bash

cpu=$(top -l 1 -n 0 | awk '/CPU usage/ {
  gsub(/[%,]/, "", $3); gsub(/[%,]/, "", $5)
  printf "%.0f%%", $3 + $5
}')

total_bytes=$(sysctl -n hw.memsize)
vm=$(vm_stat)
page_size=$(printf '%s' "$vm" | awk '/page size/ { print $8 }')
used_pages=$(printf '%s' "$vm" | awk '
  /Pages active:/                  { gsub(/\./, "", $3); a = $3 }
  /Pages wired down:/              { gsub(/\./, "", $4); w = $4 }
  /Pages occupied by compressor:/  { gsub(/\./, "", $5); c = $5 }
  END { print a + w + c }
')
ram=$(awk -v up="$used_pages" -v ps="$page_size" -v tb="$total_bytes" '
  BEGIN { printf "%.1f/%.0fG", up * ps / 1073741824, tb / 1073741824 }
')

printf "#[fg=#a6d189]CPU %s  #[fg=#babbf1]RAM %s" "$cpu" "$ram"
