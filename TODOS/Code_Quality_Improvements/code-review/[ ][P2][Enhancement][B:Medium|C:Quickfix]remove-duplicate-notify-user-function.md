# Remove Duplicate notifyUser Function

## Priority: P2 | Type: Enhancement | Benefit: Medium | Complexity: Quickfix

## Problem Description

The `notifyUser` function is implemented twice in the codebase with slightly different error handling approaches. This code duplication creates maintenance burden and potential inconsistencies in error handling behavior across the application.

**Duplicate Locations**:
1. `shell.qml` (lines 43-50) - Full implementation with try-catch error handling
2. `OverlayWindow.qml` (lines 430-433) - Property reference expecting external implementation

**Issues**:
- Code duplication increases maintenance overhead
- Different error handling approaches could lead to inconsistent behavior
- Redundant function definitions waste memory
- Changes to notification logic require updates in multiple places

## Implementation Plan

1. **Identify both implementations** of the notifyUser function
2. **Compare error handling approaches** between the two versions
3. **Keep the more robust version** (shell.qml has better error handling)
4. **Remove the duplicate** from OverlayWindow.qml
5. **Verify the property passing** from shell.qml to OverlayWindow.qml works correctly
6. **Test notification functionality** to ensure no regression

## File Locations

- `/home/jc/Dev/snippet-manager/shell.qml` (lines 43-50)
  - Primary notifyUser function with comprehensive error handling
- `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml` (lines 430-433)
  - Duplicate property that should be removed

## Success Criteria

- Only one notifyUser function exists in the codebase
- All notification calls continue to work properly
- Error handling remains consistent across the application
- Property passing from shell.qml to OverlayWindow.qml verified
- No functionality regression in desktop notifications

## Dependencies

None - This is a standalone code cleanup task.

## Code Examples

**Current Implementation - shell.qml (KEEP THIS)**:
```javascript
function notifyUser(title, message, urgency = "normal") {
    try {
        const command = ["notify-send", "-u", urgency, title, message]
        Quickshell.execDetached(command)
    } catch (error) {
        console.error("❌ Failed to send notification:", error)
    }
}
```

**Current Implementation - OverlayWindow.qml (REMOVE THIS)**:
```javascript
// Lines 430-433 - Remove this property definition
property var notifyUser: root.notifyUser
```

**Verification that Property Passing Works**:
```javascript
// In shell.qml - UI.OverlayWindow instantiation
UI.OverlayWindow {
    // ... other properties ...
    
    // Pass notification function for UI error handling
    property var notifyUser: root.notifyUser  // ✅ This should remain
}
```

**Test Commands**:
```bash
# Test notification functionality after cleanup
# Should show desktop notification
echo 'root.notifyUser("Test", "Cleanup verification", "normal")' | qs -p shell.qml --eval
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.