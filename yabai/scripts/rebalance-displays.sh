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

display_count() {
  count="$(yabai -m query --displays 2>/dev/null | "$JQ_BIN" -r 'if type == "array" then length else 0 end' 2>/dev/null || true)"
  if [ -z "${count:-}" ]; then
    count=0
  fi
  printf '%s\n' "$count"
}

spaces_json() {
  yabai -m query --spaces 2>/dev/null || echo '[]'
}

non_dashboard_space_indexes() {
  spaces_json | "$JQ_BIN" -r '[.[] | select(.uuid != "dashboard") | .index] | sort[]?'
}

space_index_by_label() {
  label="$1"
  spaces_json | "$JQ_BIN" -r --arg label "$label" \
    '.[] | select(.label == $label and .uuid != "dashboard") | .index // empty' \
    | head -n1
}

space_display_by_label() {
  label="$1"
  spaces_json | "$JQ_BIN" -r --arg label "$label" \
    '.[] | select(.label == $label and .uuid != "dashboard") | .display // empty' \
    | head -n1
}

set_space_label() {
  idx="$1"
  label="$2"

  if [ -n "${idx:-}" ]; then
    yabai -m space "$idx" --label "$label" >/dev/null 2>&1 || true
  fi
}

clear_dashboard_label() {
  dashboard_idx="$(spaces_json | "$JQ_BIN" -r '.[] | select(.uuid == "dashboard") | .index // empty' | head -n1)"
  if [ -n "${dashboard_idx:-}" ]; then
    yabai -m space "$dashboard_idx" --label "" >/dev/null 2>&1 || true
  fi
}

clear_managed_labels() {
  spaces_json | "$JQ_BIN" -r '
    .[]
    | select(
        .uuid != "dashboard"
        and (.label as $l | ["browser-main","terminal","browser-secondary","notes","pdfs","code","chat","scratch","misc","aux"] | index($l))
      )
    | .index // empty
  ' | while IFS= read -r idx; do
    if [ -n "${idx:-}" ]; then
      yabai -m space "$idx" --label "" >/dev/null 2>&1 || true
    fi
  done
}

label_for_position() {
  case "$1" in
    1) echo "browser-main" ;;
    2) echo "terminal" ;;
    3) echo "browser-secondary" ;;
    4) echo "notes" ;;
    5) echo "pdfs" ;;
    6) echo "code" ;;
    7) echo "chat" ;;
    8) echo "scratch" ;;
    9) echo "misc" ;;
    10) echo "aux" ;;
    *) echo "" ;;
  esac
}

ensure_labels() {
  pos=1
  for idx in $(non_dashboard_space_indexes); do
    label="$(label_for_position "$pos")"
    if [ -z "$label" ]; then
      break
    fi
    set_space_label "$idx" "$label"
    pos=$((pos + 1))
  done
}

move_space_to_display() {
  label="$1"
  did="$2"
  sid="$(space_index_by_label "$label")"

  if [ -z "${sid:-}" ]; then
    return 0
  fi

  current_display="$(space_display_by_label "$label")"
  if [ "${current_display:-}" = "$did" ]; then
    return 0
  fi

  yabai -m space "$sid" --display "$did" >/dev/null 2>&1 || true
}

count="$(display_count)"
clear_dashboard_label
clear_managed_labels
ensure_labels

if [ "$count" -ge 2 ]; then
  move_space_to_display "browser-main" 1
  move_space_to_display "terminal" 1
  move_space_to_display "browser-secondary" 2
  move_space_to_display "notes" 2
  move_space_to_display "pdfs" 2
  move_space_to_display "code" 1
  move_space_to_display "chat" 1
  move_space_to_display "scratch" 1
  move_space_to_display "misc" 1
  move_space_to_display "aux" 1
else
  move_space_to_display "browser-main" 1
  move_space_to_display "terminal" 1
  move_space_to_display "browser-secondary" 1
  move_space_to_display "notes" 1
  move_space_to_display "pdfs" 1
  move_space_to_display "code" 1
  move_space_to_display "chat" 1
  move_space_to_display "scratch" 1
  move_space_to_display "misc" 1
  move_space_to_display "aux" 1
fi
