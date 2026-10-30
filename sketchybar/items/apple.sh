#!/usr/bin/env bash

sketchybar --add item apple left \
  --set apple \
    icon="" \
    icon.font="SF Pro:Bold:17.0" \
    icon.color="$ACCENT" \
    icon.padding_left=10 \
    icon.padding_right=10 \
    label.drawing=off \
    padding_right=4 \
    click_script='open -a "System Settings"'
