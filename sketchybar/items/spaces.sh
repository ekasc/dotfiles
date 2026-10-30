#!/usr/bin/env bash

space_count=${#SPACE_IDS[@]}
index=0
while [ "$index" -lt "$space_count" ]; do
  sid="${SPACE_IDS[$index]}"
  letter="${SPACE_LETTERS[$index]}"
  name="space.$sid"

  sketchybar --add space "$name" left \
    --set "$name" \
      space="$sid" \
      icon="$letter" \
      icon.font="$SPACE_FONT" \
      icon.color="$MUTED" \
      label="·" \
      label.font="$TEXT_FONT_REGULAR" \
      label.color="$DIM" \
      label.max_chars=20 \
      background.color="$SURFACE" \
      background.border_color="$BORDER" \
      script="$PLUGIN_DIR/space.sh" \
      click_script="$PLUGIN_DIR/space_click.sh" \
    --subscribe "$name" \
      space_change \
      space_windows_change \
      front_app_switched \
      display_change

  index=$((index + 1))
done
