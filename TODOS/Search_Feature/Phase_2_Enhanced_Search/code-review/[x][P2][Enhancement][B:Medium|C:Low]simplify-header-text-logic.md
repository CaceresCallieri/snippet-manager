# Simplify Header Text Logic with Helper Function

## Priority: P2 | Type: Enhancement | Benefit: Medium | Complexity: Low

## Problem Description

The header text calculation in OverlayWindow.qml uses complex nested conditionals that are difficult to read, test, and maintain. The current implementation spans 20+ lines with multiple branching paths, making it prone to bugs and hard to modify.

**Current Issues**:
- Complex nested ternary operators and if-else chains
- Duplicate calculations of `currentPos`, `matchCount`, `totalCount`
- Difficult to unit test individual logic branches
- Hard to add new header text scenarios

## Implementation Plan

1. **Extract header text logic to dedicated helper function**
2. **Simplify conditional structure with early returns**
3. **Eliminate duplicate variable calculations**
4. **Add JSDoc documentation for the helper function**
5. **Test different header text scenarios**

## File Locations

- `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml` (lines 333-353)
  - Component: Header Text element with complex text binding

## Success Criteria

- Header text logic moved to readable helper function
- All existing header text scenarios work identically
- Code is more maintainable and testable
- No functional regressions
- Improved readability for future modifications

## Dependencies

None - this is a standalone refactoring improvement.

## Code Examples

**Current Complex Implementation**:
```javascript
text: {
    if (sourceSnippets.length === 0) {
        return "Snippet Manager"
    } else if (searchInput?.text && searchInput.text.length > 0) {
        const matchCount = displayedSnippets.length
        const totalCount = sourceSnippets.length
        if (matchCount === 0) {
            return `No matches for "${searchInput.text}"`
        } else if (matchCount === totalCount) {
            const currentPos = navigationController.globalIndex + 1
            return `Snippet Manager • ${currentPos}/${totalCount} selected`
        } else {
            const currentPos = navigationController.globalIndex + 1
            return `Showing ${matchCount} of ${totalCount} snippets • ${currentPos}/${matchCount} selected`
        }
    } else {
        const totalCount = sourceSnippets.length
        const currentPos = navigationController.globalIndex + 1
        return `Snippet Manager • ${currentPos}/${totalCount} selected`
    }
}
```

**Proposed Simplified Implementation**:
```javascript
/**
 * Generates appropriate header text based on current search and navigation state
 * Handles empty state, active search, and normal navigation scenarios
 * 
 * @returns {string} Formatted header text with context indicators
 * 
 * Side effects:
 * - No side effects - pure text computation function
 * - Safe for use in property bindings
 */
function getHeaderText() {
    if (sourceSnippets.length === 0) {
        return "Snippet Manager"
    }
    
    const searchActive = searchInput?.text?.length > 0
    const matchCount = displayedSnippets.length  
    const totalCount = sourceSnippets.length
    const currentPos = navigationController.globalIndex + 1
    
    // Handle search with no results
    if (searchActive && matchCount === 0) {
        return `No matches for "${searchInput.text}"`
    }
    
    // Handle filtered search results
    if (searchActive && matchCount < totalCount) {
        return `Showing ${matchCount} of ${totalCount} snippets • ${currentPos}/${matchCount} selected`
    }
    
    // Handle normal navigation (no search or showing all results)
    return `Snippet Manager • ${currentPos}/${totalCount} selected`
}

// In header Text component:
text: window.getHeaderText()
```

**Alternative Approach - Object-based State**:
```javascript
function getHeaderText() {
    const state = {
        hasSnippets: sourceSnippets.length > 0,
        searchActive: searchInput?.text?.length > 0,
        matchCount: displayedSnippets.length,
        totalCount: sourceSnippets.length,
        currentPos: navigationController.globalIndex + 1,
        searchTerm: searchInput?.text || ""
    }
    
    if (!state.hasSnippets) return "Snippet Manager"
    if (state.searchActive && state.matchCount === 0) return `No matches for "${state.searchTerm}"`
    if (state.searchActive && state.matchCount < state.totalCount) {
        return `Showing ${state.matchCount} of ${state.totalCount} snippets • ${state.currentPos}/${state.matchCount} selected`
    }
    
    return `Snippet Manager • ${state.currentPos}/${state.totalCount} selected`
}
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.