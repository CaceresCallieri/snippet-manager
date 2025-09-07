# Simplify Filtering Logic

## Priority: P1 | Type: Enhancement | Benefit: High | Complexity: Low

## Problem Description

The real-time filtering implementation contains unnecessary complexity with redundant null checks and verbose conditional logic. The current implementation performs triple null/empty checking and uses unnecessary intermediate variables, reducing code clarity and maintainability.

Issues identified:
- Triple null checking: `!searchInput || !searchInput.text || searchInput.text.length === 0`
- Verbose intermediate variable creation in filter function
- Complex conditional structure that can be simplified with modern JavaScript patterns

## Implementation Plan

1. Replace triple null checking with optional chaining (`searchInput?.text`)
2. Simplify filter logic using inline boolean expressions
3. Use default empty string fallback to eliminate multiple conditions
4. Test filtering functionality to ensure no behavior regression
5. Verify performance is maintained or improved

## File Locations

- **Primary**: `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml` (Lines 35-46)
  - `filteredSnippets` property implementation

## Success Criteria

- [ ] Code reduction: ~50% fewer lines in filtering logic
- [ ] Single null check using optional chaining pattern
- [ ] Maintained filtering behavior (title and content matching)
- [ ] No performance regression - filtering remains responsive
- [ ] Improved code readability and maintainability

## Dependencies

None - standalone code quality improvement

## Code Examples

**Current Implementation (Complex)**:
```qml
property var filteredSnippets: {
    if (!searchInput || !searchInput.text || searchInput.text.length === 0) {
        return snippets
    }
    
    const searchTerm = searchInput.text.toLowerCase()
    return snippets.filter(snippet => {
        const titleMatch = snippet.title.toLowerCase().includes(searchTerm)
        const contentMatch = snippet.content.toLowerCase().includes(searchTerm)
        return titleMatch || contentMatch
    })
}
```

**Proposed Implementation (Simplified)**:
```qml
property var filteredSnippets: {
    const searchTerm = (searchInput?.text || "").toLowerCase()
    if (!searchTerm) return snippets
    
    return snippets.filter(snippet => 
        snippet.title.toLowerCase().includes(searchTerm) ||
        snippet.content.toLowerCase().includes(searchTerm)
    )
}
```

**Benefits of Simplified Approach**:
- **Clarity**: Single null check using optional chaining
- **Conciseness**: 50% less code while maintaining identical functionality
- **Performance**: Eliminates redundant length checks
- **Maintainability**: Clear intent with inline boolean logic
- **Modern JavaScript**: Uses contemporary patterns for better code quality

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.