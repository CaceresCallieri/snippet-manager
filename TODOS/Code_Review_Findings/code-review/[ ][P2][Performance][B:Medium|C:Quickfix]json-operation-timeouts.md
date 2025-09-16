# Add Timeouts to JSON Operations

## Priority: P2 | Type: Performance | Benefit: Medium | Complexity: Quickfix

## Problem Description

The wrapper script uses synchronous `jq` calls that can block the entire wrapper when the JSON file is large, corrupted, or on slow storage. This can cause the snippet manager to hang indefinitely without user feedback, particularly problematic in network-mounted or slow storage scenarios.

## Implementation Plan

1. Add `timeout` command wrapper around `jq` calls in `lookup_snippet()`
2. Set reasonable timeout duration (2-3 seconds) for JSON operations
3. Add error handling for timeout scenarios with user notification
4. Test with large JSON files and slow storage to validate timeout effectiveness
5. Ensure timeout applies to both single and batch lookup operations

## File Locations

- `snippet-manager-wrapper.sh:95-96` - `jq` call in `lookup_snippet()` function
- `snippet-manager-wrapper.sh:89-106` - Complete `lookup_snippet()` function
- Future batch operation function (when P1 task is completed)

## Success Criteria

- JSON operations complete within 2-3 second timeout limit
- Graceful error handling when timeouts occur
- User notification for timeout scenarios via desktop notification
- No hanging processes when JSON file is slow to access
- Functionality unchanged for normal operation scenarios

## Dependencies

None

## Code Examples

**Current Blocking Implementation:**
```bash
lookup_snippet() {
    local title="$1"
    
    # This can hang indefinitely on slow storage
    content=$(jq -r --arg title "$title" '.[] | select(.title == $title) | .content' "$SNIPPETS_FILE" 2>/dev/null)
    
    if [ -n "$content" ] && [ "$content" != "null" ]; then
        echo "$content"
        return 0
    else
        return 1
    fi
}
```

**Proposed Timeout-Protected Implementation:**
```bash
lookup_snippet() {
    local title="$1"
    local timeout_duration=2  # 2 second timeout
    
    log "DEBUG" "🔍 Looking up snippet: '$title'"
    
    if [ ! -f "$SNIPPETS_FILE" ]; then
        log "ERROR" "❌ Snippets file not found: $SNIPPETS_FILE"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        log "ERROR" "❌ jq command not found - required for JSON parsing"
        return 1
    fi
    
    # Protected jq call with timeout
    local content
    if content=$(timeout "$timeout_duration" jq -r --arg title "$title" \
        '.[] | select(.title == $title) | .content' "$SNIPPETS_FILE" 2>/dev/null); then
        
        if [ -n "$content" ] && [ "$content" != "null" ]; then
            log "INFO" "✅ Found snippet content (${#content} characters)"
            echo "$content"
            return 0
        else
            log "ERROR" "❌ Snippet not found: '$title'"
            return 1
        fi
    else
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            log "ERROR" "❌ JSON lookup timed out after ${timeout_duration}s for: '$title'"
            notify_user "Snippet Manager Error" \
                "JSON lookup timed out - check file system performance" \
                "critical"
        else
            log "ERROR" "❌ JSON parsing failed for: '$title'"
        fi
        return 1
    fi
}
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.