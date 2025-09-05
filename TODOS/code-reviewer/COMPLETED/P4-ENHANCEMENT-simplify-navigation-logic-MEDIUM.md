# Simplify Complex Navigation Logic

## Priority: P4 (Low)
## Type: ENHANCEMENT
## Complexity: MEDIUM

## Problem
The navigation logic contains deeply nested conditions that are hard to follow and maintain.

## Current Complex Code
```javascript
// OverlayWindow.qml:173-188 - Hard to understand
case Qt.Key_Up:
    if (window.currentIndex > 0) {
        window.currentIndex--
    } else if (window.windowStart > 0) {
        window.windowStart--
    } else {
        // Complex wrap-around calculation
        window.windowStart = Math.max(0, snippets.length - window.maxDisplayed)
        window.currentIndex = Math.min(window.maxDisplayed - 1, snippets.length - 1 - window.windowStart)
    }
    break
```

## Issues
- Nested conditions are hard to read
- Logic is duplicated between Up/Down cases
- Wrap-around calculations are complex and error-prone
- No clear separation between different navigation behaviors

## Solution
Extract navigation logic into clear, single-purpose functions:

```javascript
// Navigation helper functions
function canMoveUpWithinWindow() {
    return currentIndex > 0
}

function canScrollWindowUp() {
    return windowStart > 0
}

function moveUpWithinWindow() {
    currentIndex--
    debugLog(`🎯 Moved up within window to index ${currentIndex}`)
}

function scrollWindowUp() {
    windowStart--
    debugLog(`🎯 Scrolled window up, start: ${windowStart}`)
}

function wrapToBottom() {
    windowStart = Math.max(0, snippets.length - maxDisplayed)
    currentIndex = Math.min(maxDisplayed - 1, snippets.length - 1 - windowStart)
    debugLog(`🎯 Wrapped to bottom, window: ${windowStart}, index: ${currentIndex}`)
}

// Clean navigation logic
case Qt.Key_Up:
    if (canMoveUpWithinWindow()) {
        moveUpWithinWindow()
    } else if (canScrollWindowUp()) {
        scrollWindowUp()
    } else {
        wrapToBottom()
    }
    break
```

## Additional Improvements
```javascript
// Extract common navigation state updates
function updateNavigationState(action) {
    debugLog(`🔵 Navigation: ${action} -> Global: ${globalIndex}, Window: ${windowStart}-${windowStart + maxDisplayed - 1}`)
    
    // Update any derived state
    // Trigger any necessary UI updates
}

// Use consistent patterns for Up/Down
function navigateUp() {
    const actions = [
        { condition: canMoveUpWithinWindow, action: moveUpWithinWindow },
        { condition: canScrollWindowUp, action: scrollWindowUp },
        { condition: () => true, action: wrapToBottom }  // default
    ]
    
    const selectedAction = actions.find(a => a.condition())
    selectedAction.action()
    updateNavigationState("UP")
}
```

## Impact
- **Before**: Complex nested conditions hard to debug and modify
- **After**: Clear, testable functions with single responsibilities

## Files to Change
- `/ui/OverlayWindow.qml` - Extract navigation helper functions
- Consider creating separate NavigationLogic.qml if functions become extensive

## Testing
1. Test all navigation scenarios still work
2. Verify wrap-around behavior is identical
3. Test edge cases (empty lists, single items)
4. Ensure debug logging is consistent