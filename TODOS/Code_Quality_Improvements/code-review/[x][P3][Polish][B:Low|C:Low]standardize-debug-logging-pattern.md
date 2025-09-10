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

## Implementation Attempt Report (2025-01-10)

### What Was Accomplished ✅
1. **Successfully updated NavigationController.qml**: 
   - Removed local `logDebug()` wrapper function  
   - Changed to direct delegation: `if (debugLog) debugLog("NavigationController: " + message)`
   - All navigation debug calls now use passed `debugLog` property directly

2. **Successfully updated shell.qml**:
   - All direct `console.log()` calls converted to use `root.debugLog()`
   - Maintained canonical `debugLog()` function as single source of truth

3. **Identified correct architecture**:
   - `shell.qml` contains the canonical `debugLog()` function
   - Components should receive `debugLog` as a property and use it directly
   - No local wrapper functions needed

### What Failed ❌
1. **OverlayWindow.qml file corruption**: 
   - Used `replace_all` on `"debugLog("` → `"root.debugLog("` 
   - This corrupted the function definition: `function root.debugLog(message)` (invalid syntax)
   - Created orphaned braces and broken file structure
   - Edit tool could not match broken syntax for subsequent fixes

2. **File restoration approach**:
   - `git checkout HEAD -- ui/OverlayWindow.qml` successfully reverted file
   - But subsequent manual edits to remove local function faced same text-matching issues

### Critical Lessons Learned 🎯

#### **NEVER use replace_all on function names in complex files**
```javascript
// DANGER: This breaks function definitions
replace_all: "debugLog(" → "root.debugLog("

// Result: function root.debugLog(message) { // INVALID!
```

#### **Safe Implementation Strategy**
1. **Start with property changes**: Update property bindings first
2. **Remove wrapper functions completely**: Don't try to modify them in-place  
3. **Use targeted replacements**: Replace function calls individually with context
4. **Test file syntax**: Verify syntax is valid after each step

#### **Correct Implementation Order**
```javascript
// Step 1: Update component property bindings
NavigationController {
    debugLog: root.debugLog  // Pass root function directly
}

// Step 2: Remove local wrapper functions entirely (not modify them)
// DELETE: function debugLog(message) { ... }

// Step 3: Update individual call sites with specific context matching
window.debugLog(`message`) → root.debugLog(`message`)
```

### Future Implementation Strategy 🛠️

**For OverlayWindow.qml specifically**:
1. **Delete the entire local `debugLog` function block** (lines 115-129) as one operation
2. **Update NavigationController property**: `debugLog: root.debugLog`  
3. **Update each `window.debugLog` call individually** with surrounding context for unique matching
4. **Test syntax validity** after each major change

**General file editing safety**:
- Use `Read` tool extensively to verify exact text before `Edit`
- Never use `replace_all` on function-related tokens 
- Make incremental changes and verify file integrity
- Keep git checkpoints for complex refactoring operations

### Current State
- **NavigationController.qml**: ✅ Fully converted to direct delegation  
- **shell.qml**: ✅ Canonical debugLog function maintained, no direct console.log calls
- **OverlayWindow.qml**: ⚠️ Partially corrupted, needs careful restoration and re-implementation

### Recommendation
Restart OverlayWindow.qml implementation with **conservative, targeted edits** and **frequent syntax validation**.

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.