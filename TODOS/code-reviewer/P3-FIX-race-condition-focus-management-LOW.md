# Fix Race Condition in Focus Management

## Priority: P3 (Medium)
## Type: FIX
## Complexity: LOW

## Problem
Multiple focus operations might conflict with HyprlandFocusGrab, potentially causing focus to be stolen or lost.

## Problematic Code
```javascript
// OverlayWindow.qml:228-243
Component.onCompleted: {
    keyHandler.focus = true
    keyHandler.forceActiveFocus()
    Qt.callLater(function() {
        keyHandler.forceActiveFocus()  // Potential conflict with HyprlandFocusGrab
    })
}
```

## Issues
- Multiple simultaneous focus operations
- Potential conflict with HyprlandFocusGrab.active = true
- Race condition between Qt focus and Hyprland focus grab

## Solution
Simplify focus management to avoid conflicts:

```javascript
Component.onCompleted: {
    // Let HyprlandFocusGrab handle the focus - it's more reliable for Wayland
    // Only set focus if HyprlandFocusGrab is not active
    if (!hyprlandFocusGrab.active) {
        keyHandler.forceActiveFocus()
    }
    
    debugLog("🎯 Focus setup completed")
}
```

Or use a more coordinated approach:
```javascript
HyprlandFocusGrab {
    id: hyprlandFocusGrab
    active: true
    
    onActiveChanged: {
        if (active) {
            // HyprlandFocusGrab is now active, ensure our handler gets focus
            Qt.callLater(function() {
                keyHandler.forceActiveFocus()
                debugLog("🎯 Focus restored after HyprlandFocusGrab activation")
            })
        }
    }
}
```

## Impact
- **Before**: Potential focus conflicts and lost keyboard input
- **After**: Reliable focus management without conflicts

## Files to Change
- `/ui/OverlayWindow.qml` Component.onCompleted section

## Testing
1. Test focus works consistently on overlay show
2. Verify no conflicts with HyprlandFocusGrab
3. Test keyboard input is always captured
4. Test with rapid overlay show/hide cycles