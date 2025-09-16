# Socat Process Cleanup and Resource Management

## Priority: P1 | Type: Fix | Benefit: High | Complexity: Low

## Problem Description

The event listener uses `socat` with a `while read` loop, but the `break` statement only exits the while loop, not the socat process itself. This creates a race condition where socat continues running even after event processing completes, causing resource leaks and orphaned processes.

## Implementation Plan

1. Replace pipe-based approach with file descriptor management
2. Use `exec` to create a controlled file descriptor for socat connection
3. Implement proper file descriptor closing to terminate socat cleanly
4. Update cleanup function to handle file descriptor termination
5. Test race condition scenarios to ensure clean termination

## File Locations

- `snippet-manager-wrapper.sh:289-298` - Current `start_event_listener()` function with socat pipe
- `snippet-manager-wrapper.sh:294-296` - Problematic while loop with break that doesn't stop socat
- `snippet-manager-wrapper.sh:188-215` - `cleanup()` function that needs FD handling

## Success Criteria

- Socat process terminates immediately when event processing completes
- No orphaned socat processes remain after wrapper script exits
- File descriptors properly closed in all termination scenarios
- Event processing functionality unchanged
- Resource usage monitoring shows clean process termination

## Dependencies

None

## Code Examples

**Current Problematic Implementation:**
```bash
socat -U - UNIX-CONNECT:"$socket_path" | while read -r line; do
    handle_event "$line"
    if [ -f "/tmp/snippet-manager-result-$$" ]; then
        break  # Only breaks while loop, socat continues running
    fi
done &
```

**Proposed File Descriptor Solution:**
```bash
start_event_listener() {
    local socket_path="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    
    log "INFO" "👂 Starting Hyprland event listener..."
    log "DEBUG" "📡 Connecting to socket: $socket_path"
    
    # Create controlled file descriptor for socat
    exec 3< <(socat -U - UNIX-CONNECT:"$socket_path")
    
    while read -r line <&3; do
        handle_event "$line"
        
        # Check if we should exit (result file was created)
        if [ -f "/tmp/snippet-manager-result-$$" ]; then
            log "DEBUG" "🔪 Event processing completed, closing connection"
            exec 3<&-  # Close the file descriptor, terminating socat
            break
        fi
    done &
    
    LISTENER_PID=$!
    log "DEBUG" "✅ Event listener started (PID: $LISTENER_PID)"
}

# Enhanced cleanup function
cleanup() {
    local exit_code=$?
    log "DEBUG" "🧹 Cleaning up wrapper process..."
    
    # Close file descriptor if still open
    if [ -n "${LISTENER_PID:-}" ]; then
        exec 3<&- 2>/dev/null || true
        if kill -0 "$LISTENER_PID" 2>/dev/null; then
            kill "$LISTENER_PID" 2>/dev/null || true
        fi
    fi
    
    # Rest of cleanup...
}
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.