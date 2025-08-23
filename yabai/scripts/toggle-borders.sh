#!/bin/bash

app=$(yabai -m query --windows --window | jq -r '.app')

# PID file for tracking the JankyBorders process
PID_FILE="/tmp/jankyborders.pid"

if [[ "$app" == "Ghostty" ]]; then
    # Check if it's already running
    if [[ ! -f $PID_FILE ]] || ! kill -0 "$(cat $PID_FILE)" 2>/dev/null; then
        # Start borders and save its PID
        borders active_color=0xFF00CC00 inactive_color=0xFF00AA00 width=3.0 &
        echo $! > "$PID_FILE"
    fi
else
    # Kill the borders process if running
    if [[ -f $PID_FILE ]]; then
        kill "$(cat $PID_FILE)" && rm -f "$PID_FILE"
    fi
fi

