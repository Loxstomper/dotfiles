#!/usr/bin/env bash
# Wi-Fi status icon + stacked network throughput.
# Updates three items: wifi (status icon), net_dn (download), net_up (upload).
# Click any of them toggles Wi-Fi power.
source "$HOME/.config/sketchybar/colors.sh"

WIFI_IF="en0"                            # Wi-Fi interface on Apple Silicon
CACHE="/tmp/sketchybar_net_${WIFI_IF}"   # holds previous counter sample
DOWN=$'\xe2\x86\x93'                     # down arrow
UP=$'\xe2\x86\x91'                       # up arrow

POWER=$(networksetup -getairportpower "$WIFI_IF" 2>/dev/null | awk '{print $NF}')
ACTIVE=$(ifconfig "$WIFI_IF" 2>/dev/null | grep -c 'status: active')

# Connection state -> icon colour + click action
if [ "$POWER" = "Off" ]; then
  COLOR="$BASE01"; CLICK="networksetup -setairportpower $WIFI_IF on"
elif [ "$ACTIVE" -gt 0 ]; then
  COLOR="$GREEN"; CLICK="networksetup -setairportpower $WIFI_IF off"
else
  COLOR="$ORANGE"; CLICK="networksetup -setairportpower $WIFI_IF off"
fi

# Human-readable byte rate
human() {
  local b=$1
  if   [ "$b" -ge 1048576 ]; then awk "BEGIN{printf \"%.1fM\", $b/1048576}"
  elif [ "$b" -ge 1024 ];    then awk "BEGIN{printf \"%.0fK\", $b/1024}"
  else                            printf '%dB' "$b"
  fi
}

# Throughput rates
if [ "$POWER" = "Off" ] || [ "$ACTIVE" -eq 0 ]; then
  rxs="--"; txs="--"
  rm -f "$CACHE"
else
  read RX TX < <(netstat -ib -I "$WIFI_IF" 2>/dev/null | awk '/<Link/ {print $7, $10; exit}')
  NOW=$(date +%s)
  if [ -f "$CACHE" ]; then
    read PREV_T PREV_RX PREV_TX < "$CACHE"
  else
    PREV_T=$NOW; PREV_RX=$RX; PREV_TX=$TX
  fi
  echo "$NOW $RX $TX" > "$CACHE"

  DT=$((NOW - PREV_T)); [ "$DT" -le 0 ] && DT=1
  RX_RATE=$(( (RX - PREV_RX) / DT )); [ "$RX_RATE" -lt 0 ] && RX_RATE=0
  TX_RATE=$(( (TX - PREV_TX) / DT )); [ "$TX_RATE" -lt 0 ] && TX_RATE=0
  rxs="$(human "$RX_RATE")"
  txs="$(human "$TX_RATE")"
fi

sketchybar --set wifi icon.color="$COLOR" click_script="$CLICK"
sketchybar --set net \
  icon="$DOWN $(printf '%5s' "$rxs")" \
  label="$UP $(printf '%5s' "$txs")" \
  click_script="$CLICK"
