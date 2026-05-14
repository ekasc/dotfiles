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

n="${1:-}"
case "$n" in
  ''|*[!0-9]*)
    exit 0
    ;;
  0)
    exit 0
    ;;
esac

idx="$(yabai -m query --spaces 2>/dev/null | "$JQ_BIN" -r --argjson n "$n" '
  [ .[] | select(.uuid != "dashboard") ] | sort_by(.index) | .[$n - 1].index // empty
' | head -n1)"

if [ -z "${idx:-}" ]; then
  exit 0
fi

yabai -m space --focus "$idx" 2>/dev/null || true
