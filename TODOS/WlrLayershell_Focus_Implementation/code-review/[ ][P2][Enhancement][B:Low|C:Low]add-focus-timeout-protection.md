# Add Focus Timeout Protection

## Priority: P2 | Type: Enhancement | Benefit: Low | Complexity: Low

## Problem Description

The current focus management uses `Qt.callLater()` to set focus on the search input, but there's no timeout protection if the delayed function fails to execute or if focus acquisition fails. This could leave users with a non-responsive overlay in edge cases.

**Potential Issues**:
- Qt.callLater may not execute if window initialization fails
- Search input may not be ready when focus is attempted
- No fallback mechanism if initial focus attempt fails
- Silent failures in focus acquisition

## Implementation Plan

1. **Add QML Timer for focus acquisition timeout**
2. **Implement retry mechanism for focus acquisition**
3. **Add focus state verification**
4. **Provide user feedback for focus failures**
5. **Set reasonable timeout duration (500-1000ms)**

## File Locations

- `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml` (lines 425-431)
  - Focus management logic in `Qt.callLater` callback

## Success Criteria

- Timer-based timeout protection for focus acquisition
- Retry mechanism when initial focus fails
- User notification for persistent focus failures
- Debug logging for focus acquisition attempts
- No impact on normal operation performance

## Dependencies

[Depends-On: extract-layershell-configuration-function] - Should implement after configuration function extraction for cleaner architecture.

## Code Examples

**Current Implementation (No Timeout Protection)**:
```qml
Qt.callLater(function() {
    if (searchInput && window.visible) {
        searchInput.forceActiveFocus()
        window.debugLog("🎯 Search input focused with WlrLayershell exclusive keyboard mode")
    }
})
```

**Proposed Implementation (With Timeout Protection)**:
```qml
Timer {
    id: focusTimeout
    interval: 500  // 500ms timeout
    running: false
    repeat: false
    
    property int attemptCount: 0
    readonly property int maxAttempts: 3
    
    onTriggered: {
        attemptCount++
        
        if (searchInput && searchInput.visible) {
            searchInput.forceActiveFocus()
            
            // Verify focus was acquired
            Qt.callLater(function() {
                if (searchInput.activeFocus) {
                    window.debugLog(`🎯 Focus acquired on attempt ${attemptCount}`)
                } else if (attemptCount < maxAttempts) {
                    window.debugLog(`⚠️ Focus attempt ${attemptCount} failed, retrying...`)
                    focusTimeout.restart()
                } else {
                    window.debugLog("❌ Focus acquisition failed after " + maxAttempts + " attempts")
                    if (notifyUser) {
                        notifyUser("Snippet Manager Warning", 
                                  "Keyboard input may not work properly", 
                                  "normal")
                    }
                }
            })
        } else {
            window.debugLog("❌ Search input not available for focus")
        }
    }
}

function initializeFocus(layerShellSuccess) {
    const focusMode = layerShellSuccess ? "WlrLayershell exclusive" : "standard"
    window.debugLog(`🎯 Initializing focus with ${focusMode} keyboard mode`)
    
    // Start focus acquisition with timeout protection
    focusTimeout.attemptCount = 0
    focusTimeout.start()
}
```

**Alternative Lightweight Implementation**:
```qml
function initializeFocus(layerShellSuccess) {
    let focusAttempts = 0
    const maxAttempts = 3
    
    function attemptFocus() {
        focusAttempts++
        
        Qt.callLater(function() {
            if (searchInput && window.visible) {
                searchInput.forceActiveFocus()
                
                // Verify after short delay
                Qt.callLater(function() {
                    if (!searchInput.activeFocus && focusAttempts < maxAttempts) {
                        window.debugLog(`⚠️ Focus attempt ${focusAttempts} failed, retrying...`)
                        attemptFocus()  // Retry
                    } else if (!searchInput.activeFocus) {
                        window.debugLog("❌ Focus acquisition failed after " + maxAttempts + " attempts")
                        if (notifyUser) {
                            notifyUser("Snippet Manager Warning", "Keyboard input may not work properly", "normal")
                        }
                    } else {
                        const focusMode = layerShellSuccess ? "WlrLayershell exclusive" : "standard"
                        window.debugLog(`🎯 Search input focused with ${focusMode} keyboard mode`)
                    }
                })
            }
        })
    }
    
    attemptFocus()
}
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.