#!/usr/bin/env bash

# Homebrew binaries are not always in launchd's default PATH.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

# Eight app-centric workspaces, matching the reference image.
# Add/remove entries in both arrays together.
SPACE_IDS=(1 2 3 4 5 6 7 8)
SPACE_LETTERS=(B C G M N S T V)

# Active workspace expands to show the focused application.
MAX_APP_NAME_CHARS=16
MAX_INACTIVE_APP_ICONS=2

TEXT_FONT="SF Pro:Semibold:13.0"
TEXT_FONT_REGULAR="SF Pro:Medium:13.0"
SPACE_FONT="SF Pro:Bold:14.0"
APP_ICON_FONT="sketchybar-app-font:Regular:16.0"

YABAI_BIN="$(command -v yabai 2>/dev/null || true)"
JQ_BIN="$(command -v jq 2>/dev/null || true)"
ICON_MAP="$CONFIG_DIR/helpers/icon_map.sh"
