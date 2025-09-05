# Add Consistent Error Handling Throughout Application

## Priority: P2 (High)
## Type: FIX
## Complexity: MEDIUM

## Problem
Error handling is inconsistent across the application, with some areas well-protected and others having no error handling.

## Current Issues
- JSON loading has good error handling ✅
- UI navigation has no error handling for edge cases ❌
- Process execution has no error handling ❌
- No validation of snippet data structure before use ❌
- Array bounds checking is inconsistent ❌

## Missing Error Handling Examples

### Process Execution
```javascript
// Current (no error handling)
Quickshell.execDetached(command)

// Should be:
try {
    Quickshell.execDetached(command)
} catch (error) {
    console.error("❌ Failed to execute injection script:", error)
    // Show user notification or fallback
}
```

### Navigation Safety
```javascript
// Current (potential crash)
window.snippetSelected(modelData)

// Should be:
if (modelData && modelData.content && modelData.title) {
    window.snippetSelected(modelData)
} else {
    console.error("❌ Invalid snippet data:", modelData)
}
```

### Array Bounds
```javascript
// Current (race condition possible)
if (window.globalIndex >= 0 && window.globalIndex < snippets.length) {
    // Array could be modified between check and use
}

// Should be:
const currentSnippets = snippets // Capture snapshot
const index = window.globalIndex
if (index >= 0 && index < currentSnippets.length && currentSnippets[index]) {
    window.snippetSelected(currentSnippets[index])
}
```

## Solution Areas
1. Add try-catch blocks around all external operations
2. Validate all data before use
3. Add fallback behaviors for error cases
4. Implement graceful degradation
5. Add user feedback for errors

## Impact
- **Before**: Crashes and undefined behavior on edge cases
- **After**: Robust application with graceful error handling

## Files to Change
- `/shell.qml` - Add process execution error handling
- `/ui/OverlayWindow.qml` - Add navigation error handling
- All components - Add data validation before use

## Testing
1. Test with malformed JSON
2. Test with missing injection script
3. Test with invalid snippet data
4. Test navigation edge cases
5. Test rapid key presses during loading