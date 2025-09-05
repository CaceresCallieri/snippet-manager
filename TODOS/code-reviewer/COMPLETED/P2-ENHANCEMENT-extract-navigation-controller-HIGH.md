# Extract Navigation Logic to Separate Controller

## Priority: P2 (High)
## Type: ENHANCEMENT
## Complexity: HIGH

## Problem
OverlayWindow.qml has 244 lines mixing UI presentation with complex navigation logic, making it hard to maintain and test.

## Current Issues
- Navigation logic tightly coupled to UI
- Multiple responsibilities in one component
- Hard to unit test navigation behavior
- Complex nested conditions difficult to follow

## Solution
Create separate NavigationController.qml:

```javascript
// NavigationController.qml
import QtQuick

QtObject {
    id: controller
    
    // Properties
    property var snippets: []
    property int currentIndex: 0
    property int windowStart: 0
    property int maxDisplayed: 5
    
    // Computed properties
    readonly property int globalIndex: windowStart + currentIndex
    readonly property var displayedSnippets: {
        if (snippets.length === 0) return []
        const end = Math.min(windowStart + maxDisplayed, snippets.length)
        return snippets.slice(windowStart, end)
    }
    
    // Signals
    signal selectionChanged()
    
    // Navigation methods
    function moveUp() {
        if (canMoveUpInWindow()) {
            moveUpInWindow()
        } else if (canScrollWindowUp()) {
            scrollWindowUp()
        } else {
            wrapToBottom()
        }
        selectionChanged()
    }
    
    function moveDown() {
        if (canMoveDownInWindow()) {
            moveDownInWindow()
        } else if (canScrollWindowDown()) {
            scrollWindowDown()
        } else {
            wrapToTop()
        }
        selectionChanged()
    }
    
    // Private helper methods
    function canMoveUpInWindow() { return currentIndex > 0 }
    function canMoveDownInWindow() { return currentIndex < Math.min(maxDisplayed - 1, displayedSnippets.length - 1) }
    function canScrollWindowUp() { return windowStart > 0 }
    function canScrollWindowDown() { return windowStart + maxDisplayed < snippets.length }
    
    function moveUpInWindow() { currentIndex-- }
    function moveDownInWindow() { currentIndex++ }
    function scrollWindowUp() { windowStart-- }
    function scrollWindowDown() { windowStart++ }
    
    function wrapToBottom() {
        windowStart = Math.max(0, snippets.length - maxDisplayed)
        currentIndex = Math.min(maxDisplayed - 1, snippets.length - 1 - windowStart)
    }
    
    function wrapToTop() {
        windowStart = 0
        currentIndex = 0
    }
}
```

## Impact
- **Before**: Monolithic UI component with mixed responsibilities
- **After**: Clean separation of navigation logic and UI presentation

## Files to Change
- Create `/ui/NavigationController.qml`
- Refactor `/ui/OverlayWindow.qml` to use controller
- Update imports and property bindings

## Testing
1. Create unit tests for navigation logic
2. Test all navigation scenarios independently
3. Verify UI still works with extracted controller