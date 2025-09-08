# Add Wayland Protocol Error Handling

## Priority: P3 | Type: Enhancement | Benefit: Medium | Complexity: Medium

## Problem Description

The current WlrLayershell implementation lacks monitoring for Wayland layer shell protocol errors or external changes to the layer shell configuration. Compositor incompatibilities or runtime changes could silently break the persistent focus behavior without user awareness.

**Potential Issues**:
- Compositor may change layer shell properties externally
- Layer shell protocol errors not handled
- Loss of exclusive keyboard focus not detected
- No recovery mechanism for protocol-level failures

## Implementation Plan

1. **Add Connections object to monitor WlrLayershell property changes**
2. **Implement handlers for layer and keyboardFocus property changes**
3. **Add automatic recovery attempts when configuration changes**
4. **Provide user notifications for persistent protocol issues**
5. **Add debug logging for all protocol state changes**

## File Locations

- `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml` (after WlrLayershell configuration)
  - Add new Connections object for protocol monitoring

## Success Criteria

- Protocol property changes detected and logged
- Automatic recovery attempts when configuration is externally modified
- User notifications for persistent protocol failures
- Debug logging for all layer shell state transitions
- No impact on normal operation performance

## Dependencies

[Depends-On: extract-layershell-configuration-function] - Should implement after configuration function extraction to reuse configuration logic for recovery.

## Code Examples

**Current Implementation (No Protocol Monitoring)**:
```qml
Component.onCompleted: {
    configureLayerShell()
    initializeFocus()
}
```

**Proposed Implementation (With Protocol Monitoring)**:
```qml
Connections {
    target: window.WlrLayershell
    enabled: window.WlrLayershell != null
    
    function onLayerChanged() {
        if (window.WlrLayershell.layer !== WlrLayer.Overlay) {
            window.debugLog(`⚠️ Layer shell layer changed externally: ${window.WlrLayershell.layer} (expected: ${WlrLayer.Overlay})`)
            
            // Attempt to restore correct layer
            try {
                window.WlrLayershell.layer = WlrLayer.Overlay
                window.debugLog("🔧 Layer restored to Overlay")
            } catch (error) {
                console.error("❌ Failed to restore layer shell layer:", error.message)
                if (notifyUser) {
                    notifyUser("Snippet Manager Warning", 
                              "Window layer changed - overlay may not stay on top", 
                              "normal")
                }
            }
        }
    }
    
    function onKeyboardFocusChanged() {
        if (window.WlrLayershell.keyboardFocus !== WlrKeyboardFocus.Exclusive) {
            window.debugLog(`⚠️ Keyboard focus changed externally: ${window.WlrLayershell.keyboardFocus} (expected: ${WlrKeyboardFocus.Exclusive})`)
            
            // Attempt to restore exclusive focus
            try {
                window.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                window.debugLog("🔧 Exclusive keyboard focus restored")
            } catch (error) {
                console.error("❌ Failed to restore exclusive keyboard focus:", error.message)
                if (notifyUser) {
                    notifyUser("Snippet Manager Warning", 
                              "Keyboard focus changed - shortcuts may dismiss overlay", 
                              "normal")
                }
            }
        }
    }
    
    function onNamespaceChanged() {
        if (window.WlrLayershell.namespace !== "snippet-manager") {
            window.debugLog(`⚠️ Layer shell namespace changed externally: '${window.WlrLayershell.namespace}' (expected: 'snippet-manager')`)
            
            // Restore namespace
            try {
                window.WlrLayershell.namespace = "snippet-manager"
                window.debugLog("🔧 Namespace restored to 'snippet-manager'")
            } catch (error) {
                console.error("❌ Failed to restore namespace:", error.message)
            }
        }
    }
}

// Enhanced configuration function with recovery support
function reconfigureLayerShell() {
    if (!window.WlrLayershell) {
        return false
    }
    
    try {
        const currentLayer = window.WlrLayershell.layer
        const currentFocus = window.WlrLayershell.keyboardFocus
        const currentNamespace = window.WlrLayershell.namespace
        
        window.WlrLayershell.layer = WlrLayer.Overlay
        window.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
        window.WlrLayershell.namespace = "snippet-manager"
        
        window.debugLog("🔧 WlrLayershell reconfigured successfully")
        return true
        
    } catch (error) {
        console.error("❌ WlrLayershell reconfiguration failed:", error.message)
        return false
    }
}
```

**Simplified Alternative (Monitoring Only)**:
```qml
Connections {
    target: window.WlrLayershell
    enabled: window.WlrLayershell != null
    
    function onLayerChanged() {
        window.debugLog(`⚠️ Layer shell layer changed: ${window.WlrLayershell.layer}`)
    }
    
    function onKeyboardFocusChanged() {
        window.debugLog(`⚠️ Keyboard focus changed: ${window.WlrLayershell.keyboardFocus}`)
        
        if (window.WlrLayershell.keyboardFocus !== WlrKeyboardFocus.Exclusive) {
            if (notifyUser) {
                notifyUser("Snippet Manager", 
                          "Focus mode changed - some shortcuts may now dismiss overlay", 
                          "low")
            }
        }
    }
}
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.