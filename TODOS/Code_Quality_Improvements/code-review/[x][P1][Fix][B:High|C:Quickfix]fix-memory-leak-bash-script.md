# Fix Memory Leak in Text Injection Script

## Priority: P1 | Type: Fix | Benefit: High | Complexity: Quickfix

## Problem Description

The `inject-text.sh` script contains a critical memory leak caused by an invalid `return` statement outside of a function context. When clipboard operations fail, the script hangs indefinitely instead of exiting properly, leaving zombie processes that consume memory and potentially interfere with subsequent text injections.

**Current Behavior**:
- Script execution hangs when `wl-copy` fails
- Process remains in memory indefinitely
- Multiple failed injections create accumulating zombie processes
- System resources slowly consumed over time

## Implementation Plan

1. **Locate the problematic return statement** in `inject-text.sh` around line 52
2. **Replace `return` with `exit 1`** for proper script termination
3. **Test clipboard failure scenario** to verify proper exit behavior
4. **Verify no other invalid return statements exist** in the script

## File Locations

- `/home/jc/Dev/snippet-manager/inject-text.sh` (line ~52)
  - Error handling block in clipboard copy operation

## Success Criteria

- Script properly exits with non-zero status when clipboard operations fail
- No hanging processes after failed text injection attempts
- Error messages still logged appropriately to stderr
- Successful text injections continue to work normally

## Dependencies

None - This is a standalone fix.

## Code Examples

**Current Implementation (Broken)**:
```bash
printf '%s' "$clean_text" | timeout 2 wl-copy 2>/dev/null || {
    echo "Warning: Failed to copy text to clipboard" >&2
    injection_success=false
    return  # ❌ INVALID - causes script to hang indefinitely
}
```

**Fixed Implementation**:
```bash
printf '%s' "$clean_text" | timeout 2 wl-copy 2>/dev/null || {
    echo "Warning: Failed to copy text to clipboard" >&2
    injection_success=false
    exit 1  # ✅ CORRECT - properly terminates script with error status
}
```

**Testing Command**:
```bash
# Simulate clipboard failure by making wl-copy unavailable
PATH="" ./inject-text.sh "test content"
# Should exit immediately with error message, not hang
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.