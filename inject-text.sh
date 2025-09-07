#!/bin/bash

# Hyprland-native text injection script for QuickShell snippet manager
# Uses Hyprland's native clipboard and key dispatch system for optimal performance
# This script runs independently after QuickShell exits to avoid interference

text="$1"

# Validate input length to prevent resource exhaustion attacks
if [[ ${#text} -gt 10000 ]]; then
    echo "Error: Text too long (max 10KB)" >&2
    exit 1
fi

# Allow QuickShell to exit completely and focus to stabilize
sleep 0.25

# Enhanced cursor positioning support and newline handling
# Check for [cursor] marker and calculate positioning
cursor_offset=0
clean_text="$text"
use_character_mode=false

if [[ "$text" == *"[cursor]"* ]]; then
    # Split text at cursor marker
    prefix="${text%%\[cursor\]*}"     # Text before marker
    suffix="${text##*\[cursor\]}"     # Text after marker
    cursor_offset=${#suffix}          # Characters to move back
    clean_text="${prefix}${suffix}"   # Text without marker
    
    echo "Cursor positioning enabled: offset ${cursor_offset} characters" >&2
fi

# Hyprland native clipboard injection for all content types
echo "Content detected (${#clean_text} chars) - using Hyprland native clipboard injection" >&2

timeout_seconds=5
injection_success=false

if command -v wl-copy >/dev/null 2>&1 && command -v hyprctl >/dev/null 2>&1; then
    # Hyprland native instant clipboard paste for all content
    echo "Using Hyprland native instant paste (minimizes clipboard pollution)" >&2
    
    # Backup current clipboard content
    original_clipboard=$(timeout 1 wl-paste 2>/dev/null || echo "")
    echo "Backed up clipboard content (${#original_clipboard} characters)" >&2
    
    # Copy snippet text to clipboard (let wl-copy run in foreground to avoid hanging)
    printf '%s' "$clean_text" | timeout 2 wl-copy 2>/dev/null || {
        echo "Warning: Failed to copy text to clipboard" >&2
        injection_success=false
        return
    }
    
    # Detect application type and use appropriate paste shortcut
    active_window_class=$(hyprctl activewindow -j 2>/dev/null | grep '"class":' | cut -d'"' -f4)
    
    if [[ "$active_window_class" == "com.mitchellh.ghostty" ]]; then
        # Ghostty terminal uses Ctrl+Shift+V
        paste_shortcut="CTRL+SHIFT,V,"
        echo "Detected Ghostty terminal - using Ctrl+Shift+V for paste" >&2
    else
        # Most other applications use Ctrl+V  
        paste_shortcut="CTRL,V,"
        echo "Detected non-terminal application ($active_window_class) - using Ctrl+V for paste" >&2
    fi
    
    # Instant paste using Hyprland's native dispatcher with detected shortcut
    if timeout 2 hyprctl dispatch sendshortcut "$paste_shortcut" 2>/dev/null; then
        echo "Hyprland instant paste completed successfully with $paste_shortcut" >&2
        injection_success=true
    else
        echo "Warning: Hyprland instant paste failed with $paste_shortcut" >&2
    fi
    
    # Always restore original clipboard content (with timeout to avoid hanging)
    printf '%s' "$original_clipboard" | timeout 2 wl-copy 2>/dev/null || {
        echo "Warning: Failed to restore original clipboard content" >&2
    }
    echo "Original clipboard content restored" >&2
fi

# Error handling if both injection methods failed
if [ "$injection_success" != "true" ]; then
    echo "Error: Text injection failed - required tools not available" >&2
    
    # Notify user of failure
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u critical "Snippet Manager" "Text injection failed - check Hyprland and wl-clipboard installation"
    fi
    
    exit 1
fi

# Position cursor if marker was found (using Hyprland key dispatch)
if [ $cursor_offset -gt 0 ]; then
    echo "Positioning cursor: moving ${cursor_offset} characters left using Hyprland dispatcher" >&2
    
    for ((i=0; i<cursor_offset; i++)); do
        timeout 1 hyprctl dispatch sendshortcut "Left" >/dev/null 2>&1 || {
            echo "Warning: Cursor positioning failed at position $i" >&2
            break
        }
    done
fi
