# Add Search TextField Component

## Context & Background

- **Feature Goal**: Implement search functionality to filter snippets in real-time
- **Current Architecture**: OverlayWindow.qml contains Column with header and NavigationController-driven snippet list
- **User Story**: Users can type search terms to quickly find specific snippets without scrolling through entire list

## Task Description

Add a styled TextField component above the snippet list that captures user input for real-time search filtering. Position it between the header and snippet list with proper styling to match the existing UI design.

## Files to Modify

- **Primary Files**:
    - `/ui/OverlayWindow.qml` (lines 45-50) – Add TextField after header, before NavigationController
    - `/utils/Constants.qml` (add new section) – Add search styling constants
- **Supporting Files**: None for this task

## Implementation Details

### Code Changes Required

```qml
// In OverlayWindow.qml - Add after header Text component
TextField {
    id: searchInput
    width: parent.width - Constants.ui.padding * 2
    height: Constants.search.inputHeight
    
    placeholderText: "Search snippets..."
    font.pixelSize: Constants.search.fontSize
    focus: true
    
    background: Rectangle {
        color: Constants.search.backgroundColor
        border.color: Constants.search.borderColor
        border.width: Constants.search.borderWidth
        radius: Constants.search.borderRadius
    }
    
    color: Constants.search.textColor
    selectionColor: Constants.search.selectionColor
    selectedTextColor: Constants.search.selectedTextColor
}
```

```qml
// In Constants.qml - Add search section
readonly property QtObject search: QtObject {
    readonly property int inputHeight: 35
    readonly property int fontSize: 14
    readonly property color backgroundColor: "#2a2a2a"
    readonly property color borderColor: "#555555"
    readonly property color textColor: "#ffffff"
    readonly property color selectionColor: "#ff6b35"
    readonly property color selectedTextColor: "#ffffff"
    readonly property int borderWidth: 1
    readonly property int borderRadius: 4
}
```

### Integration Points

- Positioned between existing header Text and NavigationController
- Uses existing Constants pattern for styling consistency
- Maintains current Column layout structure
- Focus will be managed in subsequent tasks

### Architecture Context

- Component Relationships: New search TextField integrates with existing Column layout
- State Management: TextField text will drive filtering in future tasks
- Data Flow: User input → search text property → filtering logic (Phase 1 Task 2)

### Dependencies

- Prerequisite Tasks: None (foundational task)
- Blocking Tasks: Enables Task 2 (filtering implementation) and Task 3 (keyboard navigation)
- Related Systems: Must follow Constants.qml styling patterns

### Acceptance Criteria

- TextField appears above snippet list with proper styling
- Placeholder text displays "Search snippets..."
- TextField has focus when overlay opens
- Styling matches existing UI color scheme and borders
- TextField width respects existing padding constraints
- No regressions to existing header or snippet list display

### Testing Strategy

- Manual Testing: 
  - Open overlay and verify TextField appears and has focus
  - Type text and verify it appears in the field
  - Check visual styling matches design
- Integration Tests: Ensure overlay opening/closing works unchanged
- Edge Cases: Test with empty snippets array, verify no crashes

### Implementation Notes

- Code Patterns: Follow existing Constants.qml property structure
- Performance Considerations: TextField is lightweight, no concerns
- Future Extensibility: Text property will be bound to filtering logic in Task 2

### Commit Information

- Commit Message: "feat: add search TextField component to snippet overlay"
- Estimated Time: 30 minutes
- Complexity Justification: Low - Simple UI component addition with established patterns