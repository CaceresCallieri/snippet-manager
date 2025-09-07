# Add Prefix-Based Search Modes

## Context & Background

- **Feature Goal**: Implement QuickShell launcher-style prefix search modes for targeted searching
- **Current Architecture**: Search filters both title and content fields equally with no context switching
- **User Story**: Users can type "t:function" to search only titles, or "c:email" to search only content, enabling more precise snippet discovery

## Task Description

Implement prefix-based search modes inspired by QuickShell launcher: "t:" for title-only search, "c:" for content-only search, and "tag:" for future tag-based search. Update filtering logic to detect prefixes and apply context-specific search behavior.

## Files to Modify

- **Primary Files**:
    - `/ui/OverlayWindow.qml` (filtering logic) – Update filteredSnippets to handle search modes
    - `/utils/Constants.qml` (search constants) – Add prefix definitions
- **Supporting Files**: Header text in Task 4 may need updates to reflect search mode

## Implementation Details

### Code Changes Required

```qml
// In Constants.qml - Add search mode prefixes
readonly property QtObject search: QtObject {
    // ... existing search constants ...
    readonly property string titlePrefix: "t:"
    readonly property string contentPrefix: "c:"
    readonly property string tagPrefix: "tag:"
    readonly property color prefixColor: "#4a9eff"
}
```

```qml
// In OverlayWindow.qml - Update search mode detection
property var searchMode: {
    const text = searchInput.text.toLowerCase()
    if (text.startsWith(Constants.search.titlePrefix)) {
        return { mode: "title", term: text.substring(2).trim() }
    } else if (text.startsWith(Constants.search.contentPrefix)) {
        return { mode: "content", term: text.substring(2).trim() }
    } else if (text.startsWith(Constants.search.tagPrefix)) {
        return { mode: "tag", term: text.substring(4).trim() }
    } else {
        return { mode: "all", term: text.trim() }
    }
}

// Update filteredSnippets logic
property var filteredSnippets: {
    if (searchMode.term.length === 0) {
        return loadedValidSnippets
    }
    
    const searchTerm = searchMode.term.toLowerCase()
    
    return loadedValidSnippets.filter(snippet => {
        switch (searchMode.mode) {
            case "title":
                return snippet.title.toLowerCase().includes(searchTerm)
            case "content":
                return snippet.content.toLowerCase().includes(searchTerm)
            case "tag":
                // Future: search in snippet tags
                return false
            case "all":
            default:
                const titleMatch = snippet.title.toLowerCase().includes(searchTerm)
                const contentMatch = snippet.content.toLowerCase().includes(searchTerm)
                return titleMatch || contentMatch
        }
    })
}
```

```qml
// In OverlayWindow.qml - Update search input styling for prefix detection
TextField {
    id: searchInput
    // ... existing properties ...
    
    // Highlight prefix in search field
    color: {
        if (searchMode.mode === "title" || searchMode.mode === "content") {
            return Constants.search.prefixColor
        }
        return Constants.search.textColor
    }
    
    // Update placeholder text based on mode
    placeholderText: {
        if (searchInput.text.length === 0) {
            return "Search snippets... (t: titles, c: content)"
        }
        switch (searchMode.mode) {
            case "title": return "Searching titles only..."
            case "content": return "Searching content only..."
            case "tag": return "Searching tags only..."
            default: return "Search snippets..."
        }
    }
}
```

```qml
// Update highlightSearchTerm function to use actual search term
function highlightSearchTerm(text, fullSearchText) {
    const mode = searchMode
    const searchTerm = mode.term
    
    if (!searchTerm || searchTerm.length === 0) {
        return text
    }
    
    const escapedTerm = searchTerm.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    const regex = new RegExp(`(${escapedTerm})`, 'gi')
    
    return text.replace(regex, `<span style="background-color: ${Constants.search.matchHighlightColor}; color: ${Constants.search.matchHighlightTextColor};">$1</span>`)
}
```

### Integration Points

- Search mode detection integrates with existing filtering logic
- Placeholder text provides user guidance about available prefixes
- Highlighting function uses extracted search term rather than full input text
- Header text from Task 4 can be updated to show current search mode

### Architecture Context

- Component Relationships: OverlayWindow search logic enhanced with mode detection
- State Management: Search mode computed from input text, drives filtering behavior
- Data Flow: searchInput.text → searchMode → filteredSnippets → display

### Dependencies

- Prerequisite Tasks: 
  - Task 2 (Filtering) - requires existing filteredSnippets pattern
  - Task 5 (Highlighting) - highlighting function needs update for prefix handling
- Blocking Tasks: Enables advanced search workflows and future tag-based search
- Related Systems: Uses existing filtering and Constants patterns

### Acceptance Criteria

- "t:search" filters only snippet titles
- "c:search" filters only snippet content
- Regular search without prefix searches both title and content
- Placeholder text updates to reflect current search mode
- Search input text color changes when using prefixes
- Highlighting works correctly with extracted search terms
- Mode switching works smoothly as user types
- Invalid or incomplete prefixes gracefully default to normal search

### Testing Strategy

- Manual Testing:
  - Type "t:function" and verify only title matches appear
  - Type "c:email" and verify only content matches appear
  - Test switching between modes in single session
  - Verify placeholder text changes with mode
  - Test prefix with no search term ("t:" alone)
- Integration Tests: Navigation and selection work with all search modes
- Edge Cases:
  - Prefix characters appearing in normal search terms
  - Case sensitivity of prefixes
  - Incomplete prefix typing

### Implementation Notes

- Code Patterns: Use computed property pattern for search mode detection
- Performance Considerations: Mode detection on every keystroke is lightweight
- Future Extensibility: Foundation for tag-based search and additional search modes

### Commit Information

- Commit Message: "feat: add prefix-based search modes for targeted filtering"
- Estimated Time: 60 minutes
- Complexity Justification: Medium - Requires refactoring existing search logic and coordinating multiple UI updates