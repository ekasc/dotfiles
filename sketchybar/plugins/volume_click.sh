#!/usr/bin/env bash

osascript <<'APPLESCRIPT' >/dev/null 2>&1
set currentMute to output muted of (get volume settings)
set volume output muted (not currentMute)
APPLESCRIPT
