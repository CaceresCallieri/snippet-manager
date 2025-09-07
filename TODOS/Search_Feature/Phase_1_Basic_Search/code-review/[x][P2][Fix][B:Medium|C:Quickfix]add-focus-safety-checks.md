# Add Focus Management Safety Checks

## Priority: P2 | Type: Fix | Benefit: Medium | Complexity: Quickfix

## Problem Description

The focus management implementation uses `Qt.callLater()` to coordinate with HyprlandFocusGrab, but lacks safety checks for race conditions. If the overlay is dismissed before the delayed callback executes, the `searchInput` reference may be invalid or the window may no longer be visible, potentially causing runtime errors.

Current risk: The callback assumes `searchInput` and window state remain valid when the delayed function executes, which isn't guaranteed in fast overlay show/hide scenarios.

## Implementation Plan

1. Add null safety check for `searchInput` in the Qt.callLater callback
2. Add window visibility check to ensure overlay is still active
3. Test rapid overlay show/hide scenarios to verify robustness
4. Maintain existing focus coordination behavior for normal use cases

## File Locations

- **Primary**: `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml` (Lines 168-172)
  - `HyprlandFocusGrab.onActiveChanged` handler

## Success Criteria

- [ ] Added null safety check for searchInput reference
- [ ] Added window visibility validation
- [ ] No runtime errors during rapid overlay transitions
- [ ] Existing focus behavior preserved for normal usage
- [ ] Debug logging maintained with safety context

## Dependencies

None - standalone defensive programming improvement

## Code Examples

**Current Implementation (Potential Race Condition)**:
```qml
onActiveChanged: {
    if (active) {
        Qt.callLater(function() {
            searchInput.forceActiveFocus()
            window.debugLog("🎯 Focus coordinated with HyprlandFocusGrab - search input focused")
        })
    }
}
```

**Proposed Implementation (Defensive)**:
```qml
onActiveChanged: {
    if (active) {
        Qt.callLater(function() {
            if (searchInput && window.visible) {  // Add safety checks
                searchInput.forceActiveFocus()
                window.debugLog("🎯 Focus coordinated with HyprlandFocusGrab - search input focused")
            } else {
                window.debugLog("⚠️ Focus coordination skipped - overlay no longer active")
            }
        })
    }
}
```

**Alternative Approach (Even More Defensive)**:
```qml
onActiveChanged: {
    if (active) {
        Qt.callLater(function() {
            try {
                if (searchInput && window.visible && searchInput.visible) {
                    searchInput.forceActiveFocus()
                    window.debugLog("🎯 Focus coordinated with HyprlandFocusGrab - search input focused")
                } else {
                    window.debugLog("⚠️ Focus coordination skipped - component not ready")
                }
            } catch (error) {
                window.debugLog("❌ Focus coordination failed: " + error.message)
            }
        })
    }
}
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.