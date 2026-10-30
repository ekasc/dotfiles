#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/settings.sh"

if [ -z "$YABAI_BIN" ] || [ -z "$JQ_BIN" ]; then
  sketchybar --set "$NAME" label="ERR" icon.color="$WARNING"
  exit 0
fi

layout="$($YABAI_BIN -m query --spaces --space 2>/dev/null | "$JQ_BIN" -r '.type // "bsp"' 2>/dev/null)"
case "$layout" in
  bsp)   label="BSP"; color="$ACCENT" ;;
  float) label="FLT"; color="$MUTED" ;;
  stack) label="STK"; color="$ACCENT" ;;
  *)     label="${layout:-?}"; color="$WARNING" ;;
esac

sketchybar --set "$NAME" label="$label" icon.color="$color"
