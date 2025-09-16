# Simplify Event Flow and Remove Redundant Validation

## Priority: P2 | Type: Enhancement | Benefit: Medium | Complexity: Low

## Problem Description

The current event dispatching logic creates unnecessary complexity through multiple validation passes and synthetic object creation. The flow involves: CombiningModeController validation → synthetic object creation with `isCombined` flag → shell.qml flag checking → title extraction → wrapper re-validation. This creates 4 validation passes and artificial object structures.

## Implementation Plan

1. Replace synthetic object creation with direct signal emission from CombiningModeController
2. Simplify shell.qml to handle titles array directly without checking `isCombined` flags
3. Remove intermediate object structure and validation redundancy
4. Maintain same external behavior while reducing internal complexity
5. Update signal connections to use direct title array passing

## File Locations

- `shell.qml:228-253` - Event dispatching logic with `isCombined` flag checking
- `ui/CombiningModeController.qml:241-247` - Synthetic object creation in `executeCombination()`
- `ui/CombiningModeController.qml:98-99` - `snippetReady` signal definition that could be simplified

## Success Criteria

- Eliminate synthetic object creation with `isCombined` flag
- Reduce validation passes from 4 to 2 (UI validation + wrapper validation)
- Maintain identical external behavior and error handling
- Code complexity reduction of approximately 30%
- No regression in combination functionality

## Dependencies

None

## Code Examples

**Current Over-Engineered Flow:**
```javascript
// In CombiningModeController.qml - creates synthetic object
function executeCombination() {
    const combinedSnippet = {
        title: `Combined Snippet (${combinedSnippets.length} parts)`,
        content: "", // Not used - wrapper will handle combination
        isCombined: true,
        titles: combinedSnippets.map(s => s.title)
    }
    snippetReady(combinedSnippet)
}

// In shell.qml - checks synthetic flag
onSnippetSelected: function(snippet) {
    if (snippet.isCombined && snippet.titles) {
        const titlesString = snippet.titles.join(",")
        const eventData = "COMBINED_SNIPPETS_SELECTED:" + titlesString
    } else {
        const eventData = "SNIPPET_SELECTED:" + snippet.title
    }
}
```

**Proposed Simplified Flow:**
```javascript
// In CombiningModeController.qml - direct signal emission
signal combineSnippets(var titles)

function executeCombination() {
    if (combinedSnippets.length === 0) {
        // Error handling...
        return false
    }
    
    const titles = combinedSnippets.map(s => s.title)
    combineSnippets(titles)
    return true
}

// In shell.qml - separate handlers for different events
onCombineSnippets: function(titles) {
    const eventData = "COMBINED_SNIPPETS_SELECTED:" + titles.join(",")
    Quickshell.execDetached(["hyprctl", "dispatch", "event", eventData])
    Qt.quit()
}

onSnippetSelected: function(snippet) {
    const eventData = "SNIPPET_SELECTED:" + snippet.title
    Quickshell.execDetached(["hyprctl", "dispatch", "event", eventData])
    Qt.quit()
}
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.