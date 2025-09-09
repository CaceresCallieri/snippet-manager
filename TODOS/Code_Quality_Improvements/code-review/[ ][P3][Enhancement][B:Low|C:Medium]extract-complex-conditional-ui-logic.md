# Extract Complex Conditional UI Logic

## Priority: P3 | Type: Enhancement | Benefit: Low | Complexity: Medium

## Problem Description

The `getCountText()` function in `OverlayWindow.qml` has become complex with nested conditionals that handle multiple UI states (empty snippets, search active, matches found/not found, position display). This complexity makes the function harder to test, debug, and modify, especially when adding new UI states or messages.

**Complexity Issues**:
- Multiple nested conditions in a single function
- Different logic paths for search vs non-search states
- Mixed concerns: position calculation and message formatting
- Difficult to test individual message cases
- Hard to modify specific message types without affecting others

**Current Logic Handles**:
- Empty snippet state ("No snippets available")
- No search matches ("No matches for 'term'")
- Partial matches with position ("X/Y • Y of Z total")
- Normal navigation position ("X/Y")

## Implementation Plan

1. **Analyze current getCountText() logic** and identify distinct message types
2. **Extract individual message generation functions** for each case
3. **Create helper functions** for position and match calculations
4. **Simplify main getCountText()** to delegate to specific functions
5. **Improve testability** by making functions more focused
6. **Maintain current UI behavior** while improving code structure

## File Locations

- `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml` (lines 118-140)
  - Complex `getCountText()` function with nested conditionals
  - Message formatting logic that could be extracted

## Success Criteria

- `getCountText()` function simplified to clear delegation logic
- Individual message types handled by focused functions
- Easier to test and modify specific message cases
- No change in UI behavior or message content
- Improved code readability and maintainability
- Clear separation between calculation and formatting logic

## Dependencies

None - This is a standalone code quality improvement.

## Code Examples

**Current Implementation (Complex)**:
```javascript
function getCountText() {
    if (sourceSnippets.length === 0) {
        return "No snippets available"
    }
    
    const searchActive = searchInput?.text?.length > 0
    const matchCount = displayedSnippets.length  
    const totalCount = sourceSnippets.length
    const currentPos = navigationController.globalIndex + 1
    
    if (searchActive && matchCount === 0) {
        return `No matches for "${searchInput.text}"`
    }
    
    if (searchActive && matchCount < totalCount) {
        return `${currentPos}/${matchCount} • ${matchCount} of ${totalCount} total`
    }
    
    return `${currentPos}/${totalCount}`
}
```

**Refactored Implementation (Cleaner)**:
```javascript
function getCountText() {
    if (sourceSnippets.length === 0) {
        return getEmptyStateMessage()
    }
    
    const searchActive = searchInput?.text?.length > 0
    if (searchActive) {
        return getSearchStateMessage()
    } else {
        return getNormalNavigationMessage()
    }
}

function getEmptyStateMessage() {
    return "No snippets available"
}

function getSearchStateMessage() {
    const matchCount = displayedSnippets.length
    const searchTerm = searchInput.text
    
    if (matchCount === 0) {
        return getNoMatchesMessage(searchTerm)
    }
    
    const totalCount = sourceSnippets.length
    if (matchCount < totalCount) {
        return getPartialMatchesMessage(matchCount, totalCount)
    }
    
    return getNormalNavigationMessage()
}

function getNoMatchesMessage(searchTerm) {
    return `No matches for "${searchTerm}"`
}

function getPartialMatchesMessage(matchCount, totalCount) {
    const currentPos = navigationController.globalIndex + 1
    return `${currentPos}/${matchCount} • ${matchCount} of ${totalCount} total`
}

function getNormalNavigationMessage() {
    const currentPos = navigationController.globalIndex + 1
    const totalCount = displayedSnippets.length || sourceSnippets.length
    return `${currentPos}/${totalCount}`
}
```

**Alternative Approach - State-Based**:
```javascript
function getCountText() {
    const state = determineUIState()
    
    switch (state.type) {
        case 'empty':
            return "No snippets available"
        case 'no-matches':
            return `No matches for "${state.searchTerm}"`
        case 'partial-matches':
            return `${state.currentPos}/${state.matchCount} • ${state.matchCount} of ${state.totalCount} total`
        case 'normal':
        default:
            return `${state.currentPos}/${state.totalCount}`
    }
}

function determineUIState() {
    if (sourceSnippets.length === 0) {
        return { type: 'empty' }
    }
    
    const searchActive = searchInput?.text?.length > 0
    const matchCount = displayedSnippets.length
    const totalCount = sourceSnippets.length
    const currentPos = navigationController.globalIndex + 1
    
    if (searchActive && matchCount === 0) {
        return { 
            type: 'no-matches', 
            searchTerm: searchInput.text 
        }
    }
    
    if (searchActive && matchCount < totalCount) {
        return { 
            type: 'partial-matches', 
            currentPos, 
            matchCount, 
            totalCount 
        }
    }
    
    return { 
        type: 'normal', 
        currentPos, 
        totalCount: matchCount || totalCount 
    }
}
```

**Benefits of Refactoring**:
1. **Improved Testability**: Each message type can be tested independently
2. **Easier Modification**: Changes to specific messages don't affect others
3. **Better Readability**: Clear function names describe intent
4. **Reduced Cognitive Load**: Simpler functions with single responsibilities
5. **Future Extensions**: Easy to add new message types or states

**Testing Considerations**:
```javascript
// After refactoring, individual functions can be tested:
// Test empty state
console.assert(getEmptyStateMessage() === "No snippets available")

// Test no matches  
console.assert(getNoMatchesMessage("test") === 'No matches for "test"')

// Test partial matches
console.assert(getPartialMatchesMessage(5, 20).includes("5 of 20 total"))
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.