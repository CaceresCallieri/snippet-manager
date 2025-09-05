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

# Timeout protection: prevent hanging wtype processes
timeout_seconds=5

if command -v timeout >/dev/null 2>&1; then
    # Use timeout command to bound wtype execution
    timeout ${timeout_seconds} wtype -s 5 - < <(printf '%s' "$text")
    exit_code=$?
    
    if [ $exit_code -eq 124 ]; then
        echo "Error: Text injection timed out after ${timeout_seconds} seconds" >&2
        
        # Notify user of timeout failure
        if command -v notify-send >/dev/null 2>&1; then
            notify-send -u critical "Snippet Manager" "Text injection timed out - check system responsiveness"
        fi
        
        exit 1
    elif [ $exit_code -ne 0 ]; then
        echo "Error: Text injection failed with exit code ${exit_code}" >&2
        
        # Notify user of injection failure
        if command -v notify-send >/dev/null 2>&1; then
            notify-send -u critical "Snippet Manager" "Text injection failed - check wtype installation"
        fi
        
        exit $exit_code
    fi
else
    # Fallback for systems without timeout command
    echo "Warning: timeout command not available - no timeout protection" >&2
    printf '%s' "$text" | wtype -s 5 -
fi
