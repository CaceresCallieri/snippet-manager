# Replace Manual Loops with QML Reactive Properties

## Priority: P3 | Type: Enhancement | Benefit: Low | Complexity: Quickfix

## Problem Description

The CombiningModeController uses manual loop-based character counting and explicit state management functions where QML's reactive property system could provide cleaner, more idiomatic code. The current approach requires manual `updateCharacterCount()` calls and imperative state updates.

## Implementation Plan

1. Replace manual `updateCharacterCount()` function with reactive property binding
2. Use JavaScript `reduce()` function for character counting calculation
3. Remove explicit `onCombinedSnippetsChanged` handler for character counting
4. Verify that automatic property updates work correctly
5. Test that performance is equivalent or better than manual approach

## File Locations

- `ui/CombiningModeController.qml:356-362` - Manual `updateCharacterCount()` function
- `ui/CombiningModeController.qml:53` - `combinedCharacterCount` property declaration
- `ui/CombiningModeController.qml:372-374` - `onCombinedSnippetsChanged` handler for manual updates

## Success Criteria

- Eliminate manual `updateCharacterCount()` function (6 lines removed)
- Character count updates automatically when `combinedSnippets` changes
- More idiomatic QML code using reactive properties
- No performance regression in character counting
- All existing functionality preserved

## Dependencies

None

## Code Examples

**Current Manual Implementation:**
```javascript
// Manual state management
property int combinedCharacterCount: 0

function updateCharacterCount() {
    let totalSize = 0
    for (let i = 0; i < combinedSnippets.length; i++) {
        totalSize += combinedSnippets[i].content.length
    }
    combinedCharacterCount = totalSize
}

// Manual trigger on array changes
onCombinedSnippetsChanged: {
    updateCharacterCount()
}

// Manual calls throughout code
addSnippet(snippet) {
    // ... add logic ...
    updateCharacterCount()
}
```

**Proposed Reactive Implementation:**
```javascript
// Automatic reactive property
readonly property int combinedCharacterCount: {
    return combinedSnippets.reduce((total, snippet) => total + snippet.content.length, 0)
}

// Remove manual updateCharacterCount() function entirely
// Remove onCombinedSnippetsChanged handler
// Remove manual updateCharacterCount() calls

addSnippet(snippet) {
    // ... add logic ...
    // Character count updates automatically via property binding
}
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.