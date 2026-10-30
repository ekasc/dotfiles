#!/usr/bin/env bash

sketchybar --add item yabai_mode right \
  --set yabai_mode \
    icon="Y" \
    icon.color="$ACCENT" \
    label="BSP" \
    update_freq=5 \
    script="$PLUGIN_DIR/yabai_mode.sh" \
    click_script="$PLUGIN_DIR/yabai_mode_click.sh" \
  --subscribe yabai_mode space_change

sketchybar --add item volume right \
  --set volume \
    icon="VOL" \
    icon.color="$MUTED" \
    label="--" \
    update_freq=30 \
    script="$PLUGIN_DIR/volume.sh" \
    click_script="$PLUGIN_DIR/volume_click.sh" \
  --subscribe volume volume_change

sketchybar --add item battery right \
  --set battery \
    icon="BAT" \
    icon.color="$MUTED" \
    label="--" \
    update_freq=60 \
    script="$PLUGIN_DIR/battery.sh" \
  --subscribe battery power_source_change system_woke

sketchybar --add item clock right \
  --set clock \
    icon.drawing=off \
    label="--" \
    label.padding_left=10 \
    label.padding_right=10 \
    update_freq=15 \
    script="$PLUGIN_DIR/clock.sh" \
    click_script='open -a Calendar'
