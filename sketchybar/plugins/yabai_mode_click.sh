#!/usr/bin/env bash

source "$CONFIG_DIR/settings.sh"
[ -n "$YABAI_BIN" ] && [ -n "$JQ_BIN" ] || exit 0

case "${BUTTON:-left}" in
  right)
    "$YABAI_BIN" -m space --balance >/dev/null 2>&1
    ;;
  *)
    layout="$($YABAI_BIN -m query --spaces --space 2>/dev/null | "$JQ_BIN" -r '.type // "bsp"')"
    if [ "$layout" = "float" ]; then
      "$YABAI_BIN" -m space --layout bsp >/dev/null 2>&1
    else
      "$YABAI_BIN" -m space --layout float >/dev/null 2>&1
    fi
    ;;
esac

NAME=yabai_mode "$CONFIG_DIR/plugins/yabai_mode.sh"
