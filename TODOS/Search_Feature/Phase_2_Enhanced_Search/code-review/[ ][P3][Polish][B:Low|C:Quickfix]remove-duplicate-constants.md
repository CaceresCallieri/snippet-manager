# Remove Duplicate Search Highlighting Constants

## Priority: P3 | Type: Polish | Benefit: Low | Complexity: Quickfix

## Problem Description

The Constants.qml file contains duplicate color constants for search highlighting that serve the same purpose. This creates confusion and increases maintenance overhead without providing any functional benefit.

**Current Duplication**:
- `matchHighlightColor: "#00ff00"` - Unused in current implementation
- `matchHighlightTextColor: "#00ff00"` - Actually used for highlighting

Only one constant is needed since both represent the same color value and usage pattern.

## Implementation Plan

1. **Identify which constant is actually used in the codebase**
2. **Remove the unused duplicate constant**  
3. **Verify no references to removed constant exist**
4. **Update any comments or documentation if needed**

## File Locations

- `/home/jc/Dev/snippet-manager/utils/Constants.qml` (lines 51-52)
  - `readonly property color matchHighlightColor: "#00ff00"`
  - `readonly property color matchHighlightTextColor: "#00ff00"`

## Success Criteria

- Only one search highlight color constant remains
- No broken references or compilation errors
- Codebase builds and runs successfully
- Search highlighting functionality unchanged

## Dependencies

None - this is a standalone cleanup task.

## Code Examples

**Current Duplicate Constants**:
```javascript
readonly property QtObject search: QtObject {
    // ... other properties ...
    readonly property color matchHighlightColor: "#00ff00"      // ❌ Unused
    readonly property color matchHighlightTextColor: "#00ff00"  // ✅ Used
}
```

**After Cleanup**:
```javascript
readonly property QtObject search: QtObject {
    // ... other properties ...  
    readonly property color matchHighlightTextColor: "#00ff00"
}
```

**Verification - Check Usage**:
```javascript
// In OverlayWindow.qml - confirm this is the only reference:
return text.replace(regex, `<span style="color: ${Constants.search.matchHighlightTextColor};">$1</span>`)
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.