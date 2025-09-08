# Fix Misleading Positioning Comment

## Priority: P1 | Type: Fix | Benefit: Medium | Complexity: Quickfix

## Problem Description

The comment in OverlayWindow.qml claims "Position overlay at cursor location" but the implementation uses a fixed screen percentage offset. This creates confusion about the actual positioning behavior and may mislead future developers.

**Current Issue**: Documentation doesn't match implementation, creating maintenance confusion.

## Implementation Plan

1. **Update comment to accurately reflect actual behavior**
2. **Clarify that cursor positioning is not currently implemented**
3. **Maintain existing functionality while fixing documentation**

## File Locations

- `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml` (line 402)
  - Comment: `// Position overlay at cursor location (no anchoring needed for overlay layer)`
  - Implementation: `margins.top: screen.height * Constants.overlayTopOffsetFraction`

## Success Criteria

- Comment accurately describes the positioning behavior
- No functional changes to positioning logic
- Clear indication that cursor positioning is not implemented
- Consistent documentation style with rest of codebase

## Dependencies

None - standalone documentation fix.

## Code Examples

**Current Implementation (Misleading Comment)**:
```qml
// Position overlay at cursor location (no anchoring needed for overlay layer)
margins.top: screen.height * Constants.overlayTopOffsetFraction
```

**Proposed Fix (Accurate Comment)**:
```qml
// Position overlay at fixed screen percentage (1/6 from top)
// Note: Cursor positioning not currently implemented for overlay layer
margins.top: screen.height * Constants.overlayTopOffsetFraction
```

**Alternative Clear Description**:
```qml
// Fixed positioning: overlay appears at 1/6 screen height from top
// Overlay layer positioning replaces anchor-based panel positioning
margins.top: screen.height * Constants.overlayTopOffsetFraction
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.