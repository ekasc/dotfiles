#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

status="$(pmset -g batt 2>/dev/null | tail -n 1)"
percent="$(printf '%s' "$status" | grep -Eo '[0-9]+%' | tr -d '%' | head -n 1)"
[ -n "$percent" ] || percent="?"

case "$status" in
  *AC\ Power*|*charging*|*charged*)
    icon="⚡"
    color="$ACCENT"
    ;;
  *)
    icon="BAT"
    if [ "$percent" != "?" ] && [ "$percent" -le 20 ]; then
      color="$WARNING"
    else
      color="$MUTED"
    fi
    ;;
esac

sketchybar --set "$NAME" icon="$icon" icon.color="$color" label="${percent}%"
