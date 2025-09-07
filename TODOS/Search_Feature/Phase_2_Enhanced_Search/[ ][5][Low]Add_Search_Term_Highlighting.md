# Add Search Term Highlighting in Results

## Context & Background

- **Feature Goal**: Highlight matching search terms in snippet titles and content for better visual feedback
- **Current Architecture**: Snippet items display title and content as plain text without highlighting
- **User Story**: When searching, users can quickly see which parts of snippets match their search terms through visual highlighting

## Task Description

Implement search term highlighting in snippet list items by modifying the snippet display to highlight matching text with colored backgrounds. Use rich text formatting to emphasize search matches in both title and content preview.

## Files to Modify

- **Primary Files**:
    - `/ui/OverlayWindow.qml` (snippet display logic) – Add highlighting function and apply to snippet text
    - `/utils/Constants.qml` (search constants) – Add highlighting colors
- **Supporting Files**: None for this task

## Implementation Details

### Code Changes Required

```qml
// In OverlayWindow.qml - Add highlighting helper function
function highlightSearchTerm(text, searchTerm) {
    if (!searchTerm || searchTerm.length === 0) {
        return text
    }
    
    const escapedTerm = searchTerm.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    const regex = new RegExp(`(${escapedTerm})`, 'gi')
    
    return text.replace(regex, `<span style="background-color: ${Constants.search.matchHighlightColor}; color: ${Constants.search.matchHighlightTextColor};">$1</span>`)
}
```

```qml
// In OverlayWindow.qml - Update snippet display in Repeater
Repeater {
    model: displayedSnippets
    delegate: Rectangle {
        // ... existing styling ...
        
        Column {
            // Title with highlighting
            Text {
                text: highlightSearchTerm(modelData.title, searchInput.text)
                textFormat: Text.RichText  // Enable HTML formatting
                font.pixelSize: Constants.ui.snippetTitleFontSize
                font.weight: Font.Medium
                color: isSelected ? Constants.ui.selectedTitleColor : Constants.ui.titleColor
                wrapMode: Text.Wrap
            }
            
            // Content preview with highlighting (first 100 chars)
            Text {
                text: {
                    const preview = modelData.content.length > 100 
                        ? modelData.content.substring(0, 97) + "..."
                        : modelData.content
                    return highlightSearchTerm(preview, searchInput.text)
                }
                textFormat: Text.RichText  // Enable HTML formatting
                font.pixelSize: Constants.ui.snippetContentFontSize
                color: isSelected ? Constants.ui.selectedContentColor : Constants.ui.contentColor
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }
    }
}
```

```qml
// In Constants.qml - Add highlighting colors
readonly property QtObject search: QtObject {
    // ... existing search constants ...
    readonly property color matchHighlightColor: "#ff6b35"
    readonly property color matchHighlightTextColor: "#ffffff"
    readonly property int maxPreviewLength: 100
}
```

### Integration Points

- Highlighting function integrates with existing snippet display Repeater
- Uses searchInput.text as highlight source
- Maintains existing snippet styling while adding rich text support
- Works with both title and content text fields

### Architecture Context

- Component Relationships: OverlayWindow snippet display enhanced with highlighting
- State Management: Highlighting updates automatically when search text changes
- Data Flow: searchInput.text + snippet text → highlightSearchTerm → rich text display

### Dependencies

- Prerequisite Tasks: 
  - Task 1 (Search TextField) - requires searchInput.text
  - Task 2 (Filtering) - works with filtered snippet display
- Blocking Tasks: Enhances visual feedback, prepares for Phase 3 advanced features
- Related Systems: Uses existing snippet display patterns and Constants styling

### Acceptance Criteria

- Search terms are highlighted with colored background in snippet titles
- Search terms are highlighted in content preview text
- Highlighting is case-insensitive matching search behavior
- Multiple instances of search term in same snippet are all highlighted
- Rich text formatting doesn't break existing text layout
- Highlighting disappears when search is cleared
- Performance remains smooth with typical snippet collections

### Testing Strategy

- Manual Testing:
  - Search for terms that appear in titles, verify highlighting
  - Search for terms in content, verify preview highlighting
  - Test case-insensitive highlighting matches search behavior
  - Search for partial words and verify highlighting
  - Clear search and verify highlighting disappears
- Integration Tests: Highlighting works with navigation and selection
- Edge Cases:
  - Search terms with special regex characters
  - Very long search terms
  - Search terms that appear multiple times in same snippet

### Implementation Notes

- Code Patterns: Use JavaScript regex replacement with HTML span tags
- Performance Considerations: Regex replacement is efficient for typical text lengths
- Future Extensibility: Foundation for advanced highlighting (fuzzy match highlighting, multiple term colors)

### Commit Information

- Commit Message: "feat: add search term highlighting in snippet results"
- Estimated Time: 40 minutes
- Complexity Justification: Low - Standard text highlighting with rich text formatting, well-established pattern