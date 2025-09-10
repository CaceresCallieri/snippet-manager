# Refactor Navigation Controller Complexity

## Priority: P2 | Type: Enhancement | Benefit: Medium | Complexity: High

## Problem Description

The `NavigationController.qml` component is over-engineered with 385 lines of code containing 16+ helper functions for what is essentially array index management with bounds checking. While the functionality works correctly, the complexity far exceeds what's necessary for the task, making the code harder to understand, debug, and maintain than simpler alternatives.

**Over-Engineering Issues**:
- 16+ predicate and helper functions for basic array navigation
- Complex state management for simple index calculations
- More complex than actual VS Code navigation implementation
- Difficult to modify or extend due to intricate function interdependencies
- High cognitive load for developers trying to understand navigation logic

**Current State**:
- 385 lines of navigation code
- Multiple layers of abstraction for simple operations
- Complex predicate functions that could be inline conditions
- State management overhead for straightforward calculations

## Implementation Plan

1. **Analyze current navigation requirements** and identify core functionality
2. **Design simplified architecture** with direct array manipulation
3. **Combine related helper functions** into more focused implementations
4. **Eliminate unnecessary abstraction layers** while maintaining functionality
5. **Preserve public API compatibility** for OverlayWindow integration
6. **Test thoroughly** to ensure no regression in navigation behavior
7. **Maintain wrap-around and sliding window functionality**

## File Locations

- `/home/jc/Dev/snippet-manager/ui/NavigationController.qml` (entire file, 385 lines)
  - 16+ helper functions that could be consolidated
  - Complex predicate functions for boundary conditions
  - State management that could be simplified

## Success Criteria

- Reduce code size from 385 lines to approximately 150-200 lines
- Maintain all current navigation functionality (wrap-around, sliding window)
- Preserve public API compatibility with OverlayWindow
- Improve code readability and maintainability
- No regression in navigation behavior or performance
- Easier to understand and modify for future developers

## Dependencies

This is a major refactoring that should be done when navigation functionality is stable and well-tested.

## Code Examples

**Current Approach (Over-Engineered)**:
```javascript
// Current: Multiple helper functions for simple conditions
function isAtAbsoluteTop() {
    return windowStart === 0 && currentIndex === 0
}

function isAtAbsoluteBottom() {
    return globalIndex === totalItems - 1
}

function isAtVisibleTop() {
    return currentIndex === 0
}

function isAtVisibleBottom() {
    return currentIndex === maxDisplayed - 1 || currentIndex === visibleItems - 1
}

function canScrollUp() {
    return windowStart > 0
}

function canScrollDown() {
    return windowStart + maxDisplayed < totalItems
}

// ... 10+ more similar functions
```

**Proposed Simplified Approach**:
```javascript
// Simplified: Direct calculations with clear variable names
function moveUp() {
    if (totalItems === 0) return
    
    const atAbsoluteTop = (windowStart === 0 && currentIndex === 0)
    if (atAbsoluteTop) {
        // Wrap to bottom
        windowStart = Math.max(0, totalItems - maxDisplayed)
        currentIndex = Math.min(maxDisplayed - 1, totalItems - 1)
        return
    }
    
    if (currentIndex > 0) {
        // Move within visible window
        currentIndex--
    } else {
        // Scroll window up
        windowStart = Math.max(0, windowStart - 1)
        // currentIndex stays at 0
    }
}

function moveDown() {
    if (totalItems === 0) return
    
    const atAbsoluteBottom = (globalIndex === totalItems - 1)
    if (atAbsoluteBottom) {
        // Wrap to top
        windowStart = 0
        currentIndex = 0
        return
    }
    
    const atVisibleBottom = (currentIndex === maxDisplayed - 1 || currentIndex === visibleItems - 1)
    if (atVisibleBottom && windowStart + maxDisplayed < totalItems) {
        // Scroll window down
        windowStart++
        // currentIndex stays at bottom of visible area
    } else if (currentIndex < visibleItems - 1) {
        // Move within visible window
        currentIndex++
    }
}
```

**Simplified Property Calculations**:
```javascript
// Current: Complex computed properties
readonly property int visibleItems: Math.min(maxDisplayed, Math.max(0, totalItems - windowStart))
readonly property int globalIndex: windowStart + currentIndex
readonly property var visibleSnippetWindow: {
    if (totalItems === 0) return []
    const endIndex = Math.min(windowStart + maxDisplayed, totalItems)
    return snippets.slice(windowStart, endIndex)
}

// These could remain largely the same but with simpler supporting logic
```

**Benefits of Simplification**:
1. **Reduced Cognitive Load**: Easier to understand navigation logic
2. **Improved Maintainability**: Fewer functions to track and modify
3. **Better Debuggability**: Direct calculations easier to trace
4. **Lower Bug Risk**: Fewer complex interactions between functions
5. **Easier Extensions**: Simpler base to build additional features on

## Alternative Approach - Incremental Simplification

If full refactoring is too risky, consider incremental improvements:

1. **Combine related predicates** into single functions
2. **Eliminate single-use helper functions** by inlining logic
3. **Reduce abstraction layers** while keeping core structure
4. **Simplify state management** without changing public API

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.