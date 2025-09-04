#!/bin/bash

# Detached text injection script for QuickShell snippet manager
# This script runs independently after QuickShell exits to avoid interference

text="$1"

# Allow QuickShell to exit completely and focus to stabilize
# Delay value: Constants.injectionDelayMs (250ms)
sleep 0.25

# Use wtype with small delays for reliable text injection
# -s flag adds milliseconds delay between key events to prevent issues
# Keystroke delay: Constants.wtypeKeystrokeDelayMs (5ms)
wtype -s 5 "$text"
