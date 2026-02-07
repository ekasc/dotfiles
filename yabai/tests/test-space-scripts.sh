#!/usr/bin/env sh

set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
REBALANCE_SCRIPT="$ROOT_DIR/scripts/rebalance-displays.sh"
FOCUS_SCRIPT="$ROOT_DIR/scripts/focus-space-label.sh"
MOVE_SCRIPT="$ROOT_DIR/scripts/move-window-to-space-label.sh"

JQ_BIN="$(command -v jq || true)"
if [ -z "$JQ_BIN" ]; then
  echo "ERROR: jq is required for tests."
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

MOCK_BIN="$TMP_DIR/bin"
STATE_FILE="$TMP_DIR/state.json"
DISPLAYS_FILE="$TMP_DIR/displays.json"
LOG_FILE="$TMP_DIR/log.txt"
mkdir -p "$MOCK_BIN"
: > "$LOG_FILE"

cat > "$MOCK_BIN/yabai" <<'EOF'
#!/usr/bin/env sh

set -eu

JQ_BIN="${JQ_BIN:?}"
STATE_FILE="${MOCK_STATE:?}"
DISPLAYS_FILE="${MOCK_DISPLAYS:?}"
LOG_FILE="${MOCK_LOG:?}"

printf '%s\n' "$*" >> "$LOG_FILE"

if [ "${1:-}" != "-m" ]; then
  exit 2
fi
shift

cmd="${1:-}"
shift || true

case "$cmd" in
  query)
    case "${1:-}" in
      --spaces) cat "$STATE_FILE" ;;
      --displays) cat "$DISPLAYS_FILE" ;;
      *) exit 3 ;;
    esac
    ;;
  space)
    if [ "${1:-}" = "--focus" ]; then
      idx="${2:-}"
      printf 'FOCUS_SPACE %s\n' "$idx" >> "$LOG_FILE"
      exit 0
    fi

    idx="${1:-}"
    op="${2:-}"
    val="${3:-}"

    case "$op" in
      --label)
        tmp="$STATE_FILE.tmp"
        "$JQ_BIN" --argjson idx "$idx" --arg val "$val" '
          map(if .index == $idx then .label = $val else . end)
        ' "$STATE_FILE" > "$tmp"
        mv "$tmp" "$STATE_FILE"
        ;;
      --display)
        tmp="$STATE_FILE.tmp"
        "$JQ_BIN" --argjson idx "$idx" --argjson val "$val" '
          map(if .index == $idx then .display = $val else . end)
        ' "$STATE_FILE" > "$tmp"
        mv "$tmp" "$STATE_FILE"
        ;;
      *)
        exit 4
        ;;
    esac
    ;;
  window)
    if [ "${1:-}" = "--space" ]; then
      idx="${2:-}"
      printf 'WINDOW_SPACE %s\n' "$idx" >> "$LOG_FILE"
      exit 0
    fi
    exit 5
    ;;
  *)
    exit 6
    ;;
esac
EOF
chmod +x "$MOCK_BIN/yabai"

run_with_mock() {
  PATH="$MOCK_BIN:$PATH" \
  MOCK_STATE="$STATE_FILE" \
  MOCK_DISPLAYS="$DISPLAYS_FILE" \
  MOCK_LOG="$LOG_FILE" \
  JQ_BIN="$JQ_BIN" \
  "$@"
}

write_case() {
  state_json="$1"
  displays_json="$2"
  printf '%s\n' "$state_json" > "$STATE_FILE"
  printf '%s\n' "$displays_json" > "$DISPLAYS_FILE"
  : > "$LOG_FILE"
}

label_for_index() {
  idx="$1"
  "$JQ_BIN" -r --argjson idx "$idx" '
    .[] | select(.index == $idx) | .label // empty
  ' "$STATE_FILE" | head -n1
}

display_for_label() {
  label="$1"
  "$JQ_BIN" -r --arg label "$label" '
    .[] | select(.uuid != "dashboard" and .label == $label) | .display // empty
  ' "$STATE_FILE" | head -n1
}

count_label() {
  label="$1"
  "$JQ_BIN" -r --arg label "$label" '
    [.[] | select(.uuid != "dashboard" and .label == $label)] | length
  ' "$STATE_FILE"
}

assert_eq() {
  actual="$1"
  expected="$2"
  msg="$3"
  if [ "$actual" != "$expected" ]; then
    echo "FAIL: $msg"
    echo "  expected: $expected"
    echo "  actual:   $actual"
    exit 1
  fi
}

assert_log_contains() {
  needle="$1"
  msg="$2"
  if ! grep -q "$needle" "$LOG_FILE"; then
    echo "FAIL: $msg"
    echo "  missing log pattern: $needle"
    echo "  log:"
    cat "$LOG_FILE"
    exit 1
  fi
}

assert_log_not_contains() {
  needle="$1"
  msg="$2"
  if grep -q "$needle" "$LOG_FILE"; then
    echo "FAIL: $msg"
    echo "  unexpected log pattern: $needle"
    echo "  log:"
    cat "$LOG_FILE"
    exit 1
  fi
}

test_rebalance_dual_with_dashboard() {
  write_case '
[
  {"index":1,"uuid":"A","label":"","display":1},
  {"index":2,"uuid":"B","label":"","display":1},
  {"index":3,"uuid":"dashboard","label":"","display":1},
  {"index":4,"uuid":"C","label":"","display":1},
  {"index":5,"uuid":"D","label":"","display":1},
  {"index":6,"uuid":"E","label":"","display":1}
]
' '
[{"index":1},{"index":2}]
'

  run_with_mock "$REBALANCE_SCRIPT"

  assert_eq "$(label_for_index 1)" "browser-main" "index 1 should be browser-main"
  assert_eq "$(label_for_index 2)" "terminal" "index 2 should be terminal"
  assert_eq "$(label_for_index 3)" "" "dashboard should stay unlabeled"
  assert_eq "$(label_for_index 4)" "browser-secondary" "index 4 should be browser-secondary"
  assert_eq "$(label_for_index 5)" "notes" "index 5 should be notes"
  assert_eq "$(label_for_index 6)" "pdfs" "index 6 should be pdfs"

  assert_eq "$(display_for_label browser-main)" "1" "browser-main should be on display 1"
  assert_eq "$(display_for_label terminal)" "1" "terminal should be on display 1"
  assert_eq "$(display_for_label browser-secondary)" "2" "browser-secondary should be on display 2"
  assert_eq "$(display_for_label notes)" "2" "notes should be on display 2"
  assert_eq "$(display_for_label pdfs)" "2" "pdfs should be on display 2"
}

test_rebalance_single_display_dedupes_labels() {
  write_case '
[
  {"index":1,"uuid":"A","label":"browser-main","display":2},
  {"index":2,"uuid":"B","label":"browser-main","display":2},
  {"index":3,"uuid":"dashboard","label":"terminal","display":1},
  {"index":4,"uuid":"C","label":"terminal","display":2},
  {"index":5,"uuid":"D","label":"notes","display":2}
]
' '
[{"index":1}]
'

  run_with_mock "$REBALANCE_SCRIPT"

  assert_eq "$(count_label browser-main)" "1" "browser-main label should be unique"
  assert_eq "$(count_label terminal)" "1" "terminal label should be unique"
  assert_eq "$(label_for_index 1)" "browser-main" "index 1 should be browser-main"
  assert_eq "$(label_for_index 2)" "terminal" "index 2 should be terminal"
  assert_eq "$(label_for_index 3)" "" "dashboard label should be cleared"
  assert_eq "$(label_for_index 4)" "browser-secondary" "index 4 should be browser-secondary"
  assert_eq "$(label_for_index 5)" "notes" "index 5 should be notes"

  assert_eq "$(display_for_label browser-main)" "1" "browser-main should be on display 1"
  assert_eq "$(display_for_label terminal)" "1" "terminal should be on display 1"
  assert_eq "$(display_for_label browser-secondary)" "1" "browser-secondary should be on display 1"
  assert_eq "$(display_for_label notes)" "1" "notes should be on display 1"
}

test_rebalance_is_idempotent() {
  write_case '
[
  {"index":1,"uuid":"A","label":"","display":1},
  {"index":2,"uuid":"B","label":"browser-main","display":2},
  {"index":3,"uuid":"dashboard","label":"terminal","display":1},
  {"index":4,"uuid":"C","label":"notes","display":1},
  {"index":5,"uuid":"D","label":"pdfs","display":2}
]
' '
[{"index":1},{"index":2}]
'

  run_with_mock "$REBALANCE_SCRIPT"
  first_state="$(cat "$STATE_FILE")"
  run_with_mock "$REBALANCE_SCRIPT"
  second_state="$(cat "$STATE_FILE")"

  assert_eq "$second_state" "$first_state" "rebalance should be idempotent across consecutive runs"
}

test_focus_helper_ignores_dashboard() {
  write_case '
[
  {"index":1,"uuid":"dashboard","label":"browser-secondary","display":1},
  {"index":2,"uuid":"A","label":"browser-secondary","display":2}
]
' '
[{"index":1},{"index":2}]
'

  run_with_mock "$FOCUS_SCRIPT" "browser-secondary"
  assert_log_contains "FOCUS_SPACE 2" "focus helper should focus non-dashboard index"
}

test_move_helper_moves_and_follows() {
  write_case '
[
  {"index":7,"uuid":"A","label":"notes","display":2}
]
' '
[{"index":1},{"index":2}]
'

  run_with_mock "$MOVE_SCRIPT" "notes"
  assert_log_contains "WINDOW_SPACE 7" "move helper should move window to resolved index"
  assert_log_contains "FOCUS_SPACE 7" "move helper should focus resolved index"
}

test_helpers_noop_on_unknown_label() {
  write_case '
[
  {"index":1,"uuid":"A","label":"browser-main","display":1}
]
' '
[{"index":1}]
'

  run_with_mock "$FOCUS_SCRIPT" "does-not-exist"
  run_with_mock "$MOVE_SCRIPT" "does-not-exist"
  assert_log_not_contains "FOCUS_SPACE" "unknown label should not focus any space"
  assert_log_not_contains "WINDOW_SPACE" "unknown label should not move any window"
}

test_rebalance_dual_with_dashboard
test_rebalance_single_display_dedupes_labels
test_rebalance_is_idempotent
test_focus_helper_ignores_dashboard
test_move_helper_moves_and_follows
test_helpers_noop_on_unknown_label

echo "PASS: all yabai space script tests passed."
