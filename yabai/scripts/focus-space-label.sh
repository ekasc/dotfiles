#!/usr/bin/env sh

set -u

JQ_BIN=""
if command -v jq >/dev/null 2>&1; then
  JQ_BIN="$(command -v jq)"
elif [ -x /opt/homebrew/bin/jq ]; then
  JQ_BIN="/opt/homebrew/bin/jq"
elif [ -x /usr/local/bin/jq ]; then
  JQ_BIN="/usr/local/bin/jq"
fi

if [ -z "$JQ_BIN" ]; then
  exit 0
fi

label="${1:-}"
if [ -z "$label" ]; then
  exit 0
fi

idx="$(yabai -m query --spaces 2>/dev/null | "$JQ_BIN" -r --arg label "$label" \
  '.[] | select(.label == $label and .uuid != "dashboard") | .index // empty' | head -n1)"

if [ -z "${idx:-}" ]; then
  exit 0
fi

yabai -m space --focus "$idx" 2>/dev/null || true
