# Optimize Search Highlighting Performance

## Priority: P2 | Type: Performance | Benefit: High | Complexity: Medium

## Problem Description

The current search highlighting implementation recalculates highlighting for every snippet on every render cycle. This creates redundant text processing that impacts performance, especially with larger snippet collections and real-time search updates.

**Current Inefficiency**:
- `highlightSearchTerm()` called for each snippet on each render
- Same text processing repeated unnecessarily
- Potential UI stutter during fast typing

## Implementation Plan

1. **Move highlighting computation to `displayedSnippets` property**
2. **Pre-compute highlighted text during filtering phase**
3. **Update snippet display to use pre-computed highlighted text**
4. **Maintain existing search functionality and reactivity**
5. **Test performance improvement with large snippet collections**

## File Locations

- `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml` (lines 35-43, 453)
  - Property: `displayedSnippets` filtering logic
  - Component: Text element in snippet Repeater

## Success Criteria

- Highlighting calculations happen only once per search term change
- Smooth UI performance during real-time search
- No regression in search functionality or visual appearance
- Memory usage remains stable
- Code remains readable and maintainable

## Dependencies

[Depends-On: html-injection-vulnerability] - Should implement secure highlighting first before optimizing.

## Code Examples

**Current Inefficient Implementation**:
```javascript
// In snippet Repeater Text component - runs on every render
text: window.highlightSearchTerm(modelData.title || "Untitled", searchInput?.text || "")

// Current displayedSnippets - only does filtering
property var displayedSnippets: {
    const searchTerm = (searchInput?.text || "").toLowerCase()
    if (!searchTerm) return sourceSnippets
    
    return sourceSnippets.filter(snippet => 
        snippet.title.toLowerCase().includes(searchTerm) ||
        snippet.content.toLowerCase().includes(searchTerm)
    )
}
```

**Proposed Optimized Implementation**:
```javascript
// Enhanced displayedSnippets - filtering + highlighting in one pass
property var displayedSnippets: {
    const searchTerm = (searchInput?.text || "").toLowerCase()
    const searchText = searchInput?.text || ""
    
    if (!searchTerm) {
        return sourceSnippets.map(snippet => ({
            ...snippet,
            highlightedTitle: escapeHtml(snippet.title)
        }))
    }
    
    return sourceSnippets.filter(snippet => 
        snippet.title.toLowerCase().includes(searchTerm) ||
        snippet.content.toLowerCase().includes(searchTerm)
    ).map(snippet => ({
        ...snippet,
        highlightedTitle: window.highlightSearchTerm(snippet.title, searchText)
    }))
}

// Simplified Text component - uses pre-computed highlighting
text: modelData.highlightedTitle || "Untitled"
```

**Alternative Approach - Separate Highlighted Data Property**:
```javascript
property var highlightedSnippets: {
    const searchText = searchInput?.text || ""
    return displayedSnippets.map(snippet => 
        window.highlightSearchTerm(snippet.title, searchText)
    )
}

// In Repeater model binding
model: navigationController.visibleSnippetWindow

// In Text component
text: window.highlightedSnippets[navigationController.visibleRangeStartIndex + index] || modelData.title || "Untitled"
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.