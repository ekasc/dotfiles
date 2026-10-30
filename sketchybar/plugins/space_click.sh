#!/usr/bin/env bash

source "$CONFIG_DIR/settings.sh"

sid="${NAME#space.}"
[ -n "$YABAI_BIN" ] || exit 0

# Left-click focuses. Right-click moves the focused window and follows it.
case "${BUTTON:-left}" in
  right)
    "$YABAI_BIN" -m window --space "$sid" >/dev/null 2>&1 && \
      "$YABAI_BIN" -m space --focus "$sid" >/dev/null 2>&1
    ;;
  *)
    "$YABAI_BIN" -m space --focus "$sid" >/dev/null 2>&1
    ;;
esac
