#!/usr/bin/env bash
# CPU + memory drawn as two stacked lines in one item:
#   icon  = CPU line (top)
#   label = memory line (bottom)
source "$HOME/.config/sketchybar/colors.sh"

CPU_GLYPH=$'\xef\x8b\x9b'   # nf-fa-microchip
MEM_GLYPH=$'\xee\xbf\x85'   # nf-fa-memory

# --- CPU usage (user + sys) ---
CPU_LINE=$(top -l 2 -n 0 -s 1 | grep -E "^CPU usage" | tail -1)
CU=$(echo "$CPU_LINE" | awk '{print $3}' | tr -d '%')
CS=$(echo "$CPU_LINE" | awk '{print $5}' | tr -d '%')
CPU=$(echo "$CU $CS" | awk '{printf "%d", $1 + $2}')
[ -z "$CPU" ] && CPU=0

if   [ "$CPU" -ge 80 ]; then CPU_COLOR="$RED"
elif [ "$CPU" -ge 50 ]; then CPU_COLOR="$YELLOW"
else                         CPU_COLOR="$GREEN"
fi

# --- Memory usage (percentage in use) ---
FREE=$(memory_pressure 2>/dev/null | awk '/free percentage:/ {print $NF}' | tr -d '%')
[ -z "$FREE" ] && FREE=100
MEM=$((100 - FREE))

if   [ "$MEM" -ge 85 ]; then MEM_COLOR="$RED"
elif [ "$MEM" -ge 65 ]; then MEM_COLOR="$YELLOW"
else                         MEM_COLOR="$GREEN"
fi

sketchybar --set sys \
  icon="$CPU_GLYPH $(printf '%4s' "${CPU}%")"  icon.color="$CPU_COLOR" \
  label="$MEM_GLYPH $(printf '%4s' "${MEM}%")" label.color="$MEM_COLOR"
