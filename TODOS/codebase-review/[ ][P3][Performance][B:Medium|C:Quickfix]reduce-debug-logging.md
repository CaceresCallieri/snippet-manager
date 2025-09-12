# Reduce Debug Logging Overhead

## Priority: P3 | Type: Performance | Benefit: Medium | Complexity: Quickfix

## Problem Description

Debug logging in navigation hot paths impacts runtime performance, especially in the `NavigationController.qml` component where logging occurs on every arrow key press. This creates unnecessary overhead in production usage where debug output is not needed.

## Implementation Plan

1. Add conditional checks before all debug logging calls
2. Focus on high-frequency paths like navigation functions
3. Ensure debug logging only occurs when debug function is provided
4. Test that performance improves in normal usage

## File Locations

- `ui/NavigationController.qml` lines 110-172
- Functions: `moveUp()`, `moveDown()`, and navigation helpers
- Any other high-frequency debug logging locations

## Success Criteria

- Debug logging only executes when debug function is available
- Navigation performance noticeably improved
- All existing debug functionality preserved when debug mode enabled
- No broken debug output

## Dependencies

None

## Code Examples

**Current Unconditional Logging:**
```javascript
function moveUp() {
    // ... navigation logic
    debugLog(`Navigation UP: Global ${globalIndex}`)
    selectionChanged()
}

function moveDown() {
    // ... navigation logic  
    debugLog(`Navigation DOWN: Global ${globalIndex}`)
    selectionChanged()
}
```

**Proposed Conditional Logging:**
```javascript
function moveUp() {
    // ... navigation logic
    if (debugLog) {  // Only log if debug function provided
        debugLog(`Navigation UP: Global ${globalIndex}`)
    }
    selectionChanged()
}

function moveDown() {
    // ... navigation logic
    if (debugLog) {  // Only log if debug function provided
        debugLog(`Navigation DOWN: Global ${globalIndex}`)
    }
    selectionChanged()
}
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.