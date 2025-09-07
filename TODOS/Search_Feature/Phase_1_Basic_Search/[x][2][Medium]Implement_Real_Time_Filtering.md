# Implement Real-Time Filtering Logic

## Context & Background

- **Feature Goal**: Filter snippet list based on search input, showing only matching results
- **Current Architecture**: NavigationController receives full snippets array and manages navigation
- **User Story**: As user types in search field, snippet list updates instantly to show only relevant matches

## Task Description

Implement real-time filtering that connects search TextField text to NavigationController's snippet data. Create filtered array that updates on every keystroke, with case-insensitive matching against both title and content fields.

## Files to Modify

- **Primary Files**:
    - `/ui/OverlayWindow.qml` (lines 60-70) – Add filteredSnippets property and search logic
    - `/ui/NavigationController.qml` (property binding) – Update to use filteredSnippets instead of full snippets array
- **Supporting Files**: None for this task

## Implementation Details

### Code Changes Required

```qml
// In OverlayWindow.qml - Add after searchInput TextField
property var filteredSnippets: {
    if (!searchInput.text || searchInput.text.length === 0) {
        return loadedValidSnippets
    }
    
    const searchTerm = searchInput.text.toLowerCase()
    return loadedValidSnippets.filter(snippet => {
        const titleMatch = snippet.title.toLowerCase().includes(searchTerm)
        const contentMatch = snippet.content.toLowerCase().includes(searchTerm)
        return titleMatch || contentMatch
    })
}

// Update NavigationController instantiation
NavigationController {
    id: navigationController
    snippets: filteredSnippets  // Changed from loadedValidSnippets
    maxDisplayed: Constants.ui.maxVisibleSnippets
    onSelectionChanged: displayedSnippets = visibleSnippetWindow
}
```

```qml
// In NavigationController.qml - ensure reset behavior on model change
onSnippetsChanged: {
    // Reset navigation when filtered results change
    visibleRangeStartIndex = 0
    currentIndex = 0
    if (snippets.length > 0) {
        selectionChanged()
    }
}
```

### Integration Points

- Connects searchInput.text to NavigationController's data source
- Maintains existing NavigationController API unchanged
- Preserves all existing navigation and selection behavior
- Works with empty state handling already implemented

### Architecture Context

- Component Relationships: OverlayWindow manages filtering, NavigationController handles navigation
- State Management: Search text drives filtered array, which drives navigation state
- Data Flow: searchInput.text → filteredSnippets → NavigationController → displayedSnippets

### Dependencies

- Prerequisite Tasks: Task 1 (Add Search TextField) - requires searchInput.text property
- Blocking Tasks: Enables Task 3 (keyboard navigation from search field)
- Related Systems: Uses existing loadedValidSnippets validation and NavigationController patterns

### Acceptance Criteria

- Typing in search field immediately filters snippet list
- Case-insensitive matching against both title and content
- Empty search shows all snippets
- Navigation resets to first item when search changes
- No performance issues with typical snippet collections (10-50 items)
- Empty state handling works when no snippets match search
- All existing navigation behavior preserved with filtered results

### Testing Strategy

- Manual Testing:
  - Type various search terms and verify correct filtering
  - Test case variations (uppercase, lowercase, mixed)
  - Verify both title and content matching
  - Clear search and verify all snippets return
  - Test with empty search (should show all)
- Integration Tests: Navigation should work correctly with filtered results
- Edge Cases: 
  - Search term that matches no snippets (empty state)
  - Very long search terms
  - Special characters in search

### Implementation Notes

- Code Patterns: Use computed property pattern for reactive filtering
- Performance Considerations: JavaScript filter() is efficient for typical snippet counts
- Future Extensibility: Filtering logic can be enhanced with fuzzy matching or weighted scoring

### Commit Information

- Commit Message: "feat: implement real-time search filtering for snippet list"
- Estimated Time: 45 minutes
- Complexity Justification: Medium - Requires understanding data flow between components and ensuring state synchronization