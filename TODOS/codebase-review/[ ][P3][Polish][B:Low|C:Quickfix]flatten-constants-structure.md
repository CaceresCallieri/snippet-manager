# Flatten Constants Structure

## Priority: P3 | Type: Polish | Benefit: Low | Complexity: Quickfix

## Problem Description

Deeply nested constant objects make access verbose and reduce developer experience. Instead of writing `Constants.search.matchHighlightTextColor`, developers should be able to use simpler names like `Constants.searchHighlightColor` for commonly used values.

## Implementation Plan

1. Identify most frequently used nested constants
2. Create flat aliases for commonly accessed properties
3. Update usage throughout codebase to use simpler names
4. Keep existing nested structure for backward compatibility initially
5. Test that all constants resolve correctly

## File Locations

- `utils/Constants.qml` - main constants definition
- All files using deeply nested constants (search for `Constants.search.`, `Constants.colors.`, etc.)

## Success Criteria

- Commonly used constants have flat aliases
- All constant references work correctly
- Developer experience improved for frequent constants
- No breaking changes to existing functionality

## Dependencies

None

## Code Examples

**Current Verbose Access:**
```qml
// Current nested access
color: Constants.search.matchHighlightTextColor
height: Constants.layout.searchInputHeight
color: Constants.colors.selectedBackground
```

**Proposed Flattened Access:**
```qml
// In Constants.qml - add flat aliases
readonly property color searchHighlightColor: search.matchHighlightTextColor
readonly property int searchInputHeight: layout.searchInputHeight
readonly property color selectedBackground: colors.selectedBackground

// Usage becomes simpler
color: Constants.searchHighlightColor
height: Constants.searchInputHeight
color: Constants.selectedBackground
```

**Most Common Constants to Flatten:**
- `Constants.search.matchHighlightTextColor` → `Constants.searchHighlightColor`
- `Constants.colors.selectedBackground` → `Constants.selectedBackground`
- `Constants.colors.unselectedBackground` → `Constants.unselectedBackground`
- `Constants.colors.mainBorder` → `Constants.mainBorder`
- `Constants.layout.searchInputHeight` → `Constants.searchInputHeight`

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.