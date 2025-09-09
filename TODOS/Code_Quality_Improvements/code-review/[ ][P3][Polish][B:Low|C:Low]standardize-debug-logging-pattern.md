# Standardize Debug Logging Pattern

## Priority: P3 | Type: Polish | Benefit: Low | Complexity: Low

## Problem Description

The codebase uses inconsistent debug logging approaches throughout different components, with some using `window.debugLog()`, others using `controller.debugLog()`, and potentially some using direct `console.log()`. This inconsistency creates a fragmented debugging experience and makes it difficult to control logging behavior consistently across the application.

**Inconsistency Issues**:
- Mixed usage of `window.debugLog()` vs `controller.debugLog()`
- Unclear which logging method should be used in different contexts
- Potential direct console.log usage bypassing the debug system
- Inconsistent emoji markers and formatting across components
- Difficulty in globally controlling debug output

## Implementation Plan

1. **Audit all debug logging calls** across the codebase
2. **Identify the canonical debug logging method** (likely `window.debugLog` from shell.qml)
3. **Create consistent logging guidelines** for different component types
4. **Replace inconsistent logging calls** with the standardized approach
5. **Verify debug toggle functionality** works consistently
6. **Update any documentation** to reflect the standard approach

## File Locations

- `/home/jc/Dev/snippet-manager/shell.qml` 
  - Primary `debugLog()` function definition
- `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml`
  - Various debug logging calls that may be inconsistent
- `/home/jc/Dev/snippet-manager/ui/NavigationController.qml`
  - Navigation-related debug logging calls
- Search for all instances of `debugLog`, `console.log` in codebase

## Success Criteria

- All debug logging uses consistent method (`window.debugLog()`)
- Debug toggle functionality works uniformly across all components
- Consistent emoji markers and message formatting
- No direct console.log calls that bypass debug system
- Clear documentation of which logging method to use in different contexts
- Improved debugging experience with uniform output format

## Dependencies

None - This is a standalone code quality improvement.

## Code Examples

**Current Inconsistent Usage**:
```javascript
// In different files, various patterns exist:
window.debugLog("🎯 Focus message")           // Pattern A
controller.debugLog("🔍 Navigation message")  // Pattern B  
console.log("Debug message")                  // Pattern C (bypasses debug toggle)
```

**Standardized Approach (Recommended)**:
```javascript
// In shell.qml - Keep this as the canonical implementation
function debugLog(message) {
    if (isDebugLoggingEnabled) {
        console.log(message)
    }
}

// In all other components - Use window.debugLog consistently
window.debugLog("🎯 Consistent logging with emoji markers")
window.debugLog("🔍 Navigation state change")
window.debugLog("⚠️ Warning message with standard formatting")
```

**Pattern Guidelines**:
```javascript
// Component initialization
window.debugLog("🚀 ComponentName initialized")

// User interactions  
window.debugLog("🎯 User action: " + actionDescription)

// State changes
window.debugLog("🔄 State change: " + stateDescription)

// Warnings
window.debugLog("⚠️ Warning: " + warningMessage)

// Errors (for debug context, not user errors)
window.debugLog("❌ Debug error: " + errorMessage)

// Performance/calculations
window.debugLog("📊 Performance: " + performanceData)
```

**Implementation Steps**:
1. **Search and identify** all logging patterns:
   ```bash
   grep -r "debugLog\|console\.log" --include="*.qml" .
   ```

2. **Replace inconsistent calls**:
   ```javascript
   // Replace this pattern
   controller.debugLog("message")
   
   // With this pattern
   window.debugLog("message")
   ```

3. **Verify debug toggle** works for all logging calls

## Alternative Approach - Component-Specific Logging

If different components need their own logging control:

```javascript
// In each component, create a local debug function that delegates to window
function debugLog(message) {
    if (window.debugLog) {
        window.debugLog(`[${componentName}] ${message}`)
    }
}
```

This maintains consistency while allowing component-specific prefixes.

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.