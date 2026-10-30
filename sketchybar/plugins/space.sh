#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/settings.sh"

sid="${NAME#space.}"

# Fail visibly instead of silently producing stale workspace state.
if [ -z "$YABAI_BIN" ] || [ -z "$JQ_BIN" ]; then
  sketchybar --set "$NAME" \
    drawing=on \
    icon.color="$WARNING" \
    label="!" \
    label.font="$TEXT_FONT" \
    label.color="$WARNING"
  exit 0
fi

spaces_json="$($YABAI_BIN -m query --spaces 2>/dev/null || printf '[]')"
exists="$(printf '%s' "$spaces_json" | "$JQ_BIN" -r --argjson sid "$sid" '[.[] | select(.index == $sid)] | length' 2>/dev/null)"

if [ "${exists:-0}" -eq 0 ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

focused_sid="$(printf '%s' "$spaces_json" | "$JQ_BIN" -r '.[] | select(."has-focus" == true) | .index' 2>/dev/null | head -n 1)"
windows_json="$($YABAI_BIN -m query --windows --space "$sid" 2>/dev/null || printf '[]')"
window_count="$(printf '%s' "$windows_json" | "$JQ_BIN" -r '[.[] | select(."is-minimized" == false)] | length' 2>/dev/null)"

if [ "$focused_sid" = "$sid" ]; then
  app="$($YABAI_BIN -m query --windows --window 2>/dev/null | "$JQ_BIN" -r '.app // empty' 2>/dev/null)"
  [ -n "$app" ] || app="Desktop"

  if [ "${#app}" -gt "$MAX_APP_NAME_CHARS" ]; then
    app="${app:0:$MAX_APP_NAME_CHARS}…"
  fi

  sketchybar --animate tanh 18 --set "$NAME" \
    drawing=on \
    icon.color="$ACCENT" \
    label="$app" \
    label.font="$TEXT_FONT_REGULAR" \
    label.color="$TEXT" \
    label.padding_left=4 \
    label.padding_right=10 \
    background.color="$SURFACE_ACTIVE" \
    background.border_color="$BORDER_ACTIVE"
  exit 0
fi

icons=""
if [ "${window_count:-0}" -gt 0 ] && [ -x "$ICON_MAP" ]; then
  apps="$(printf '%s' "$windows_json" | "$JQ_BIN" -r --argjson max "$MAX_INACTIVE_APP_ICONS" '[.[] | select(."is-minimized" == false and .app != "") | .app] | unique | .[:$max][]' 2>/dev/null)"
  while IFS= read -r app; do
    [ -n "$app" ] || continue
    mapped="$($ICON_MAP "$app" 2>/dev/null | awk '{print $1}')"
    [ -n "$mapped" ] || continue
    if [ -n "$icons" ]; then
      icons="$icons $mapped"
    else
      icons="$mapped"
    fi
  done <<EOF_APPS
$apps
EOF_APPS
fi

if [ -n "$icons" ]; then
  inactive_label="$icons"
  inactive_font="$APP_ICON_FONT"
  inactive_color="$MUTED"
elif [ "${window_count:-0}" -gt 0 ]; then
  inactive_label="$window_count"
  inactive_font="$TEXT_FONT"
  inactive_color="$MUTED"
else
  inactive_label="·"
  inactive_font="$TEXT_FONT_REGULAR"
  inactive_color="$DIM"
fi

sketchybar --animate tanh 18 --set "$NAME" \
  drawing=on \
  icon.color="$MUTED" \
  label="$inactive_label" \
  label.font="$inactive_font" \
  label.color="$inactive_color" \
  label.padding_left=3 \
  label.padding_right=8 \
  background.color="$SURFACE" \
  background.border_color="$BORDER"
