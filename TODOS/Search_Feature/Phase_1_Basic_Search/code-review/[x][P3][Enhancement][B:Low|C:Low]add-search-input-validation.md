# Add Search Input Validation

## Priority: P3 | Type: Enhancement | Benefit: Low | Complexity: Low

## Problem Description

The search TextField currently accepts unlimited input length and any characters without validation. While not critical for basic functionality, this could lead to performance issues with extremely long search terms or unexpected behavior with special characters in edge cases.

Current state: No input length limits, no character filtering, no validation of search content.

Potential issues:
- Very long search strings could impact filtering performance
- Special regex characters in search might cause unexpected behavior in future fuzzy search implementations
- No user feedback for invalid or problematic search terms

## Implementation Plan

1. Add maximum search length limit (e.g., 100 characters)
2. Consider basic character validation if needed for future fuzzy search compatibility
3. Add visual feedback for search term truncation if implemented
4. Test with various search patterns to ensure robustness
5. Document search input limitations in code comments

## File Locations

- **Primary**: `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml` (Lines 207-285)
  - Search TextField component and related handlers
- **Secondary**: `/home/jc/Dev/snippet-manager/utils/Constants.qml`
  - Could add search-related constants for limits

## Success Criteria

- [ ] Search input length limited to reasonable maximum (100 characters suggested)
- [ ] User receives visual feedback if input is truncated
- [ ] No breaking changes to existing search functionality
- [ ] Search performance maintained or improved
- [ ] Documentation updated with input validation rules

## Dependencies

None - standalone enhancement, though benefits from completing higher-priority simplification tasks first

## Code Examples

**Current Implementation (No Validation)**:
```qml
TextField {
    id: searchInput
    placeholderText: "Search snippets..."
    font.pixelSize: Constants.search.fontSize
    focus: true
    // No validation or length limits
}
```

**Proposed Implementation (With Validation)**:
```qml
TextField {
    id: searchInput
    placeholderText: "Search snippets..."
    font.pixelSize: Constants.search.fontSize
    focus: true
    
    // Add input validation
    property int maxSearchLength: Constants.search.maxInputLength || 100
    
    onTextChanged: {
        if (text.length > maxSearchLength) {
            // Truncate input and provide feedback
            text = text.substring(0, maxSearchLength)
            window.debugLog("⚠️ Search input truncated to " + maxSearchLength + " characters")
            
            // Optional: Could add visual feedback like temporary color change
            // or tooltip showing truncation occurred
        }
    }
}
```

**Alternative Approach (More User-Friendly)**:
```qml
TextField {
    id: searchInput
    placeholderText: "Search snippets..."
    font.pixelSize: Constants.search.fontSize
    focus: true
    
    property int maxSearchLength: 100
    
    // Prevent input beyond limit rather than truncating
    validator: RegularExpressionValidator {
        regularExpression: new RegExp("^.{0," + searchInput.maxSearchLength + "}$")
    }
    
    // Optional: Show character count for long searches
    Text {
        visible: parent.text.length > 50
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 2
        text: parent.text.length + "/" + parent.maxSearchLength
        font.pixelSize: 8
        color: parent.text.length >= parent.maxSearchLength ? "#ff6b35" : "#aaaaaa"
    }
}
```

**Constants Addition**:
```qml
// In Constants.qml
readonly property QtObject search: QtObject {
    // ... existing properties ...
    readonly property int maxInputLength: 100
    readonly property color warningColor: "#ff6b35"
}
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.