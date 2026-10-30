#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

volume="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null || printf '0')"
muted="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null || printf 'false')"

if [ "$muted" = "true" ] || [ "$volume" -eq 0 ]; then
  sketchybar --set "$NAME" label="MUTE" icon.color="$DIM"
else
  sketchybar --set "$NAME" label="${volume}%" icon.color="$MUTED"
fi
