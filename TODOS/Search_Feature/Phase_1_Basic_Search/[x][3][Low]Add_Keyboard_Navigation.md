# Add Keyboard Navigation from Search Field

## Context & Background

- **Feature Goal**: Enable seamless keyboard navigation between search input and snippet selection using QuickShell launcher patterns
- **Current Architecture**: NavigationController handles Up/Down arrows for snippet navigation, search TextField currently captures all input
- **User Story**: Users can type to search, then use arrow keys to navigate results without losing search focus or switching focus contexts

## Task Description

Implement the QuickShell launcher pattern where search TextField maintains focus while Up/Down arrow keys directly control NavigationController selection. Add Enter key handling for snippet selection and Escape key for search clearing or overlay dismissal.

## Files to Modify

- **Primary Files**:
    - `/ui/OverlayWindow.qml` (searchInput Keys handlers) – Add keyboard navigation delegation
- **Supporting Files**: `/ui/NavigationController.qml` may need minor updates for external control

## Implementation Details

### Code Changes Required

```qml
// In OverlayWindow.qml - Update searchInput TextField
TextField {
    id: searchInput
    // ... existing properties ...
    focus: true  // Always maintain focus
    
    Keys.onUpPressed: {
        event.accepted = true
        if (filteredSnippets.length > 0) {
            navigationController.moveUp()
        }
    }
    
    Keys.onDownPressed: {
        event.accepted = true
        if (filteredSnippets.length > 0) {
            navigationController.moveDown()
        }
    }
    
    Keys.onReturnPressed: {
        event.accepted = true
        if (filteredSnippets.length > 0) {
            const selectedSnippet = navigationController.getSelectedSnippet()
            onSnippetSelected(selectedSnippet)
        }
    }
    
    Keys.onEnterPressed: {
        event.accepted = true
        if (filteredSnippets.length > 0) {
            const selectedSnippet = navigationController.getSelectedSnippet()
            onSnippetSelected(selectedSnippet)
        }
    }
    
    Keys.onEscapePressed: {
        event.accepted = true
        if (searchInput.text.length > 0) {
            // First escape clears search
            searchInput.text = ""
        } else {
            // Second escape (or escape with empty search) exits
            Qt.quit()
        }
    }
}
```

```qml
// In NavigationController.qml - Add external control methods if needed
function moveUp() {
    moveSelectionUp()
}

function moveDown() {
    moveSelectionDown()
}

function getSelectedSnippet() {
    if (snippets.length === 0 || currentIndex < 0) return null
    const globalIdx = visibleRangeStartIndex + currentIndex
    return snippets[globalIdx] || null
}
```

### Integration Points

- Search TextField delegates arrow keys to NavigationController while maintaining focus
- Enter key triggers same snippet selection as existing click/enter behaviors
- Escape key provides progressive dismissal (clear search → exit overlay)
- NavigationController public API may need expansion for external control

### Architecture Context

- Component Relationships: OverlayWindow orchestrates between search input and navigation
- State Management: Search field focus is permanent, navigation state controlled via delegation
- Data Flow: Keyboard events → search field → NavigationController methods → snippet selection

### Dependencies

- Prerequisite Tasks: 
  - Task 1 (Search TextField) - requires searchInput component
  - Task 2 (Filtering) - requires filteredSnippets array and navigation state
- Blocking Tasks: Completes basic search functionality, enables Phase 2 enhancements
- Related Systems: Uses existing NavigationController selection and onSnippetSelected patterns

### Acceptance Criteria

- Up/Down arrows navigate snippet list while search field retains focus
- Enter key selects current snippet and triggers text injection
- Escape key clears search if text exists, exits overlay if search is empty
- Arrow navigation wraps correctly at list boundaries
- Visual selection highlighting works during keyboard navigation
- Search text remains editable during navigation
- No focus switching between search field and snippet list

### Testing Strategy

- Manual Testing:
  - Type search term, use arrows to navigate, verify highlight moves
  - Press Enter on selected snippet, verify injection works
  - Test Escape behavior: first clears search, second exits
  - Verify wrapping at top/bottom of filtered results
  - Test with single search result
- Integration Tests: Ensure existing mouse navigation still works
- Edge Cases:
  - Navigation with empty search results
  - Keyboard navigation with single snippet
  - Rapid key presses and state consistency

### Implementation Notes

- Code Patterns: Follow QuickShell launcher pattern - search keeps focus, arrows delegate
- Performance Considerations: Key delegation is lightweight, no concerns
- Future Extensibility: Foundation for advanced keyboard shortcuts (Ctrl+J/K, Tab navigation)

### Commit Information

- Commit Message: "feat: add keyboard navigation from search field using launcher pattern"
- Estimated Time: 30 minutes
- Complexity Justification: Low - Simple key event delegation with established NavigationController API