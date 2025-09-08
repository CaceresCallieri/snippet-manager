# Extract LayerShell Configuration Function

## Priority: P2 | Type: Enhancement | Benefit: Medium | Complexity: Low

## Problem Description

The WlrLayershell configuration logic is currently embedded within `Component.onCompleted`, mixing concerns of window initialization, layer shell setup, and focus management. This makes the code harder to test, maintain, and extend.

**Current Issues**:
- Mixed responsibilities in Component.onCompleted
- No clear separation between configuration and initialization
- Difficult to add comprehensive error handling
- Hard to test configuration logic independently

## Implementation Plan

1. **Extract configuration logic into dedicated function**
2. **Add comprehensive error handling with try-catch blocks**
3. **Return success/failure status for downstream logic**
4. **Separate focus management from configuration**
5. **Add function-level JSDoc documentation**

## File Locations

- `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml` (lines 411-431)
  - `Component.onCompleted` block containing WlrLayershell configuration

## Success Criteria

- Configuration logic extracted into standalone function
- Clear success/failure return values
- Comprehensive error handling with user notifications
- Separation of concerns between configuration and focus management
- JSDoc documentation for the new function
- Existing functionality preserved

## Dependencies

[Depends-On: add-focus-acquisition-verification] - Should implement verification first to avoid conflicts.

## Code Examples

**Current Implementation (Mixed Concerns)**:
```qml
Component.onCompleted: {
    console.log("OverlayWindow: Created with", sourceSnippets.length, "snippets")
    
    // Configure Wayland layer shell for persistent focus
    if (window.WlrLayershell != null) {
        window.WlrLayershell.layer = WlrLayer.Overlay
        window.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
        window.WlrLayershell.namespace = "snippet-manager"
        window.debugLog("🔧 WlrLayershell configured: Overlay layer with exclusive keyboard focus")
    } else {
        window.debugLog("⚠️ WlrLayershell not available - exclusive focus may not work")
    }
    
    // Ensure search input gets focus once window is ready
    Qt.callLater(function() {
        if (searchInput && window.visible) {
            searchInput.forceActiveFocus()
            window.debugLog("🎯 Search input focused with WlrLayershell exclusive keyboard mode")
        }
    })
}
```

**Proposed Implementation (Separated Concerns)**:
```qml
/**
 * Configures Wayland layer shell for persistent focus overlay
 * Sets up exclusive keyboard mode to prevent system shortcuts from dismissing overlay
 * 
 * @returns {boolean} True if configuration was successful, false otherwise
 * 
 * Side effects:
 * - Sets WlrLayershell.layer to WlrLayer.Overlay
 * - Sets WlrLayershell.keyboardFocus to WlrKeyboardFocus.Exclusive  
 * - Sets WlrLayershell.namespace to "snippet-manager"
 * - Logs configuration status and sends user notifications on errors
 */
function configureLayerShell() {
    if (!window.WlrLayershell) {
        window.debugLog("⚠️ WlrLayershell not available - falling back to standard window mode")
        if (notifyUser) {
            notifyUser("Snippet Manager", 
                      "Running in compatibility mode - some shortcuts may dismiss overlay", 
                      "low")
        }
        return false
    }
    
    try {
        window.WlrLayershell.layer = WlrLayer.Overlay
        window.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
        window.WlrLayershell.namespace = "snippet-manager"
        
        window.debugLog("🔧 WlrLayershell configured successfully")
        return true
        
    } catch (error) {
        console.error("❌ WlrLayershell configuration failed:", error.message)
        if (notifyUser) {
            notifyUser("Snippet Manager Error", 
                      "Focus configuration failed - overlay may not work properly", 
                      "critical")
        }
        return false
    }
}

/**
 * Ensures search input receives focus after window initialization
 * Uses Qt.callLater to avoid race conditions with window setup
 * 
 * @param {boolean} layerShellSuccess - Whether layer shell configuration succeeded
 */
function initializeFocus(layerShellSuccess) {
    Qt.callLater(function() {
        if (searchInput && window.visible) {
            searchInput.forceActiveFocus()
            const focusMode = layerShellSuccess ? "WlrLayershell exclusive" : "standard"
            window.debugLog(`🎯 Search input focused with ${focusMode} keyboard mode`)
        }
    })
}

Component.onCompleted: {
    console.log("OverlayWindow: Created with", sourceSnippets.length, "snippets")
    
    const layerShellSuccess = configureLayerShell()
    initializeFocus(layerShellSuccess)
}
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.