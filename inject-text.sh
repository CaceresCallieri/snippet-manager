#!/bin/bash

# Detached text injection script for QuickShell snippet manager
# This script runs independently after QuickShell exits to avoid interference

text="$1"

# Validate input length to prevent resource exhaustion attacks
if [[ ${#text} -gt 10000 ]]; then
    echo "Error: Text too long (max 10KB)" >&2
    exit 1
fi

# Allow QuickShell to exit completely and focus to stabilize
# Delay value: Constants.injectionDelayMs (250ms)
sleep 0.25

# Use printf with stdin for secure text injection (prevents argument parsing exploits)
# -s flag adds milliseconds delay between key events to prevent issues
# Keystroke delay: Constants.wtypeKeystrokeDelayMs (5ms)
printf '%s' "$text" | wtype -s 5 -
