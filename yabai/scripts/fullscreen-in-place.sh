#!/usr/bin/env sh
# ---------------------------------------------------------------------------
# fullscreen-in-place: keep native fullscreen in the current space.
#
# When macOS creates a new Space for a native-fullscreen window (green button
# or ctrl+cmd+f), yabai appends it at the END of the space list. This handler
# fires on `space_created`, detects the native-fullscreen window, exits native
# fullscreen (window returns home, the empty Space is destroyed) and zooms the
# window in place instead -- so you never leave your current desktop.
#
# A short visual flash during the conversion is expected.
# ---------------------------------------------------------------------------

SPACE_ID="${YABAI_SPACE_ID:-}"
SPACE_INDEX="${YABAI_SPACE_INDEX:-}"
[ -z "$SPACE_ID" ] && exit 0

# --- serialization: space_created can fire twice per fullscreen entry -------
LOCK="$HOME/.cache/yabai-fs-in-place.lock"
mkdir -p "$(dirname "$LOCK")" 2>/dev/null
if [ -e "$LOCK" ]; then
    # break stale locks older than 60s
    if [ "$(find "$LOCK" -mmin +1 2>/dev/null)" ]; then
        rm -rf "$LOCK"
    else
        exit 0
    fi
fi
mkdir "$LOCK" 2>/dev/null || exit 0
trap 'rm -rf "$LOCK"' EXIT

# --- give macOS a moment to finish the space transition ----------------------
sleep 0.3

WID=$(yabai -m query --windows --space "$SPACE_INDEX" 2>/dev/null | \
    python3 -c '
import json, sys
try:
    wins = json.load(sys.stdin)
except Exception:
    wins = []
native = [w["id"] for w in wins if w.get("is-native-fullscreen", False)]
print(native[0] if native else "")
')

[ -z "$WID" ] && exit 0

# --- only act if the window is still in native fullscreen --------------------
STATE=$(yabai -m query --windows --window "$WID" 2>/dev/null) || exit 0
echo "$STATE" | grep -q '"is-native-fullscreen": true' || exit 0

# --- exit native fullscreen; the window returns to its original space -------
yabai -m window "$WID" --toggle native-fullscreen 2>/dev/null
sleep 0.4

# --- zoom it in place (retry once, window may still be settling) ------------
yabai -m window "$WID" --toggle zoom-fullscreen 2>/dev/null
sleep 0.3
yabai -m query --windows --window "$WID" 2>/dev/null | grep -q '"has-fullscreen-zoom": true' || \
    yabai -m window "$WID" --toggle zoom-fullscreen 2>/dev/null

exit 0
