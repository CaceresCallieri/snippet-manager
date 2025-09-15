#!/bin/bash

# Snippet Manager Wrapper Script
# Event-driven architecture using Hyprland's native event system
# Eliminates timing issues and provides deterministic execution

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SNIPPETS_FILE="$SCRIPT_DIR/data/snippets.json"
PID_FILE="/tmp/snippet-manager-wrapper.pid"
DEBUG_MODE=true

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%H:%M:%S')
    
    case "$level" in
        "INFO")  echo -e "${GREEN}[${timestamp}]${NC} ${message}" >&2 ;;
        "WARN")  echo -e "${YELLOW}[${timestamp}]${NC} ${message}" >&2 ;;
        "ERROR") echo -e "${RED}[${timestamp}]${NC} ${message}" >&2 ;;
        "DEBUG") [ "$DEBUG_MODE" = "true" ] && echo -e "${BLUE}[${timestamp}]${NC} ${message}" >&2 ;;
    esac
}

# Function to check if Hyprland is available
check_hyprland() {
    if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        log "ERROR" "❌ HYPRLAND_INSTANCE_SIGNATURE not set - not running under Hyprland"
        return 1
    fi
    
    local socket_path="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    if [ ! -S "$socket_path" ]; then
        log "ERROR" "❌ Hyprland event socket not found: $socket_path"
        return 1
    fi
    
    if ! command -v hyprctl >/dev/null 2>&1; then
        log "ERROR" "❌ hyprctl command not found"
        return 1
    fi
    
    log "DEBUG" "✅ Hyprland environment validated"
    return 0
}

# Function to check for single instance
check_single_instance() {
    if [ -f "$PID_FILE" ]; then
        local old_pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
        if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
            log "ERROR" "❌ Another wrapper instance is already running (PID: $old_pid)"
            return 1
        else
            log "WARN" "⚠️ Removing stale PID file"
            rm -f "$PID_FILE"
        fi
    fi
    
    # Write our PID
    echo $$ > "$PID_FILE"
    log "DEBUG" "✅ Single instance protection enabled (PID: $$)"
    return 0
}

# Function to lookup snippet content by title
lookup_snippet() {
    local title="$1"
    
    log "DEBUG" "🔍 Looking up snippet: '$title'"
    
    if [ ! -f "$SNIPPETS_FILE" ]; then
        log "ERROR" "❌ Snippets file not found: $SNIPPETS_FILE"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        log "ERROR" "❌ jq command not found - required for JSON parsing"
        return 1
    fi
    
    # Use jq with proper argument passing to handle special characters
    local content
    content=$(jq -r --arg title "$title" '.[] | select(.title == $title) | .content' "$SNIPPETS_FILE" 2>/dev/null)
    
    if [ -n "$content" ] && [ "$content" != "null" ]; then
        log "INFO" "✅ Found snippet content (${#content} characters)"
        echo "$content"
        return 0
    else
        log "ERROR" "❌ Snippet not found: '$title'"
        return 1
    fi
}

# Function to send desktop notification
notify_user() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u "$urgency" "$title" "$message"
        log "DEBUG" "🔔 Notification sent: $title - $message"
    else
        log "WARN" "⚠️ notify-send not available, cannot send notification"
    fi
}

# Function to inject text using existing script
inject_text() {
    local content="$1"
    local inject_script="$SCRIPT_DIR/inject-text.sh"
    
    if [ ! -x "$inject_script" ]; then
        log "ERROR" "❌ Injection script not found or not executable: $inject_script"
        notify_user "Snippet Manager Error" "Injection script missing or not executable"
        return 1
    fi
    
    log "INFO" "🚀 Injecting text (${#content} characters)"
    
    # Execute injection script with content
    if "$inject_script" "$content"; then
        log "INFO" "✅ Text injection completed successfully"
        return 0
    else
        log "ERROR" "❌ Text injection failed"
        notify_user "Snippet Manager Error" "Failed to inject text"
        return 1
    fi
}

# Cleanup function
cleanup() {
    local exit_code=$?
    log "DEBUG" "🧹 Cleaning up wrapper process..."
    
    # Kill QuickShell if still running
    if [ -n "${QUICKSHELL_PID:-}" ]; then
        if kill -0 "$QUICKSHELL_PID" 2>/dev/null; then
            log "DEBUG" "🔪 Terminating QuickShell process (PID: $QUICKSHELL_PID)"
            kill "$QUICKSHELL_PID" 2>/dev/null || true
        fi
    fi
    
    # Kill event listener if running
    if [ -n "${LISTENER_PID:-}" ]; then
        if kill -0 "$LISTENER_PID" 2>/dev/null; then
            log "DEBUG" "🔪 Terminating event listener (PID: $LISTENER_PID)"
            kill "$LISTENER_PID" 2>/dev/null || true
        fi
    fi
    
    # Remove PID file and result file
    rm -f "$PID_FILE"
    rm -f "/tmp/snippet-manager-result-$$"
    
    log "DEBUG" "✅ Cleanup completed (exit code: $exit_code)"
    exit $exit_code
}

# Set up signal handlers
trap cleanup EXIT INT TERM

# Event handler function following Hyprland documentation pattern
handle_event() {
    local event="$1"
    log "DEBUG" "📨 Received event: $event"
    
    case "$event" in
        custom\>\>SNIPPET_SELECTED:*)
            # Extract title from event
            local selected_title="${event#custom>>SNIPPET_SELECTED:}"
            
            log "INFO" "📋 Snippet selected: '$selected_title'"
            
            # Lookup content from JSON file
            log "DEBUG" "🔍 Starting snippet lookup for: '$selected_title'"
            if snippet_content=$(lookup_snippet "$selected_title"); then
                log "DEBUG" "✅ Lookup successful, content length: ${#snippet_content}"
                # Inject immediately (no delay needed!)
                log "DEBUG" "🚀 Starting text injection..."
                if inject_text "$snippet_content"; then
                    log "INFO" "🎉 Snippet injection completed successfully"
                    echo "SUCCESS" > "/tmp/snippet-manager-result-$$"
                else
                    log "ERROR" "❌ Injection failed for: '$selected_title'"
                    echo "FAILED" > "/tmp/snippet-manager-result-$$"
                fi
            else
                log "ERROR" "❌ Lookup failed for: '$selected_title'"
                notify_user "Snippet Manager Error" "Failed to find snippet: $selected_title" "critical"
                echo "FAILED" > "/tmp/snippet-manager-result-$$"
            fi
            ;;
        custom\>\>SNIPPET_CANCELLED*)
            log "INFO" "❌ User cancelled selection"
            echo "CANCELLED" > "/tmp/snippet-manager-result-$$"
            ;;
    esac
}

# Function to start event listener using Hyprland documentation pattern
start_event_listener() {
    local socket_path="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    
    log "INFO" "👂 Starting Hyprland event listener..."
    log "DEBUG" "📡 Connecting to socket: $socket_path"
    
    # Use the official Hyprland pattern from documentation
    socat -U - UNIX-CONNECT:"$socket_path" | while read -r line; do
        handle_event "$line"
        
        # Check if we should exit (result file was created)
        if [ -f "/tmp/snippet-manager-result-$$" ]; then
            log "DEBUG" "🔪 Event processing completed, exiting listener"
            break
        fi
    done &
    
    LISTENER_PID=$!
    log "DEBUG" "✅ Event listener started (PID: $LISTENER_PID)"
}

# Function to launch QuickShell UI
launch_quickshell() {
    log "INFO" "🚀 Launching QuickShell UI..."
    
    # Set environment variables
    export QML_XHR_ALLOW_FILE_READ=1
    
    # Launch QuickShell
    qs -p "$SCRIPT_DIR/shell.qml" &
    QUICKSHELL_PID=$!
    
    log "DEBUG" "✅ QuickShell launched (PID: $QUICKSHELL_PID)"
}

# Main execution
main() {
    log "INFO" "🎯 Starting Snippet Manager Wrapper"
    
    # Validate environment
    if ! check_hyprland; then
        log "ERROR" "❌ Hyprland validation failed - falling back to direct mode"
        # TODO: Implement fallback to direct QuickShell mode
        exit 1
    fi
    
    # Ensure single instance
    if ! check_single_instance; then
        exit 1
    fi
    
    # Start event listener
    start_event_listener
    
    # Give event listener a moment to establish connection
    sleep 0.1
    
    # Launch QuickShell UI
    launch_quickshell
    
    # Wait for either:
    # 1. Event listener to signal completion (via flag file)
    # 2. QuickShell to exit (user cancellation without event)
    log "DEBUG" "⏳ Waiting for snippet selection or QuickShell exit..."
    
    local result_file="/tmp/snippet-manager-result-$$"
    local timeout_seconds=30
    local elapsed=0
    
    # Monitor for completion
    while [ $elapsed -lt $timeout_seconds ]; do
        # Check if event listener signaled completion
        if [ -f "$result_file" ]; then
            local result=$(cat "$result_file" 2>/dev/null)
            rm -f "$result_file"
            
            if [ "$result" = "SUCCESS" ]; then
                log "INFO" "🎉 Snippet processing completed successfully"
            elif [ "$result" = "CANCELLED" ]; then
                log "INFO" "❌ User cancelled selection via event"
            else
                log "WARN" "⚠️ Unknown result: $result"
            fi
            
            # Kill QuickShell if still running
            if kill -0 "$QUICKSHELL_PID" 2>/dev/null; then
                kill "$QUICKSHELL_PID" 2>/dev/null
            fi
            return 0
        fi
        
        # Check if QuickShell exited without sending event
        if ! kill -0 "$QUICKSHELL_PID" 2>/dev/null; then
            log "DEBUG" "📋 QuickShell exited - waiting briefly for events..."
            sleep 1  # Give events time to be processed
            
            if [ -f "$result_file" ]; then
                local result=$(cat "$result_file" 2>/dev/null)
                rm -f "$result_file"
                log "INFO" "✅ Event processed after QuickShell exit: $result"
                return 0
            else
                log "INFO" "📋 QuickShell exited without event processing"
                return 1
            fi
        fi
        
        sleep 0.1
        elapsed=$((elapsed + 1))
    done
    
    log "WARN" "⏰ Timeout waiting for completion"
    rm -f "$result_file"
}

# Run main function
main "$@"