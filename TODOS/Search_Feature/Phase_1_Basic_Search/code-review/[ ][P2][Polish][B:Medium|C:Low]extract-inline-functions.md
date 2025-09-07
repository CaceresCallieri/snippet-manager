# Extract Large Inline Functions to Named Functions

## Priority: P2 | Type: Polish | Benefit: Medium | Complexity: Low

## Problem Description

Several key handlers contain large inline function implementations that reduce code readability and make testing more difficult. Functions like the Enter key handler (20+ lines) and escape key handler (10+ lines) are embedded directly in property declarations, making the QML code harder to scan and understand.

Large inline functions identified:
- Enter key handling logic (both Return and Enter handlers - addresses after duplicate removal)
- Escape key progressive behavior logic
- Up/Down arrow delegation handlers

## Implementation Plan

1. Extract Enter key handler to named function (after duplicate removal task)
2. Extract Escape key handler with progressive behavior logic
3. Extract arrow key delegation functions for consistency
4. Ensure all extracted functions maintain existing behavior
5. Update JSDoc documentation for extracted functions
6. Test all keyboard interactions to verify no regression

## File Locations

- **Primary**: `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml` (Lines 231-284)
  - Various `Keys.on*Pressed` handlers with large inline implementations
  - Search TextField component area

## Success Criteria

- [ ] All keyboard handlers use named function references instead of large inline functions
- [ ] Extracted functions have clear, descriptive names
- [ ] JSDoc documentation added for extracted functions
- [ ] No behavior changes - all keyboard interactions work identically
- [ ] Improved code readability and maintainability
- [ ] Functions are testable in isolation (future benefit)

## Dependencies

- **Depends-On**: remove-duplicate-enter-handlers - Must complete Enter handler deduplication first

## Code Examples

**Current Implementation (Large Inline Functions)**:
```qml
Keys.onEscapePressed: function(event) {
    event.accepted = true
    if (searchInput.text.length > 0) {
        // First escape clears search
        window.debugLog("🧹 Escape pressed - clearing search text")
        searchInput.text = ""
    } else {
        // Second escape (or escape with empty search) exits
        window.debugLog("🔴 Escape pressed - dismissing overlay")
        Qt.quit()
    }
}

Keys.onUpPressed: function(event) {
    event.accepted = true
    if (window.hasValidSnippets) {
        window.debugLog("⬆️ Up arrow delegated from search field to NavigationController")
        navigationController.moveUp()
    }
}
```

**Proposed Implementation (Named Functions)**:
```qml
/**
 * Handles progressive Escape key behavior: clear search then exit overlay
 * First press clears search text, second press (or empty search) exits
 * 
 * @param {Object} event - Keyboard event object
 */
function handleEscapeKey(event) {
    event.accepted = true
    if (searchInput.text.length > 0) {
        // First escape clears search
        window.debugLog("🧹 Escape pressed - clearing search text")
        searchInput.text = ""
    } else {
        // Second escape (or escape with empty search) exits
        window.debugLog("🔴 Escape pressed - dismissing overlay")
        Qt.quit()
    }
}

/**
 * Delegates up arrow navigation to NavigationController while maintaining search focus
 * 
 * @param {Object} event - Keyboard event object
 */
function handleUpArrow(event) {
    event.accepted = true
    if (window.hasValidSnippets) {
        window.debugLog("⬆️ Up arrow delegated from search field to NavigationController")
        navigationController.moveUp()
    }
}

/**
 * Delegates down arrow navigation to NavigationController while maintaining search focus
 * 
 * @param {Object} event - Keyboard event object
 */
function handleDownArrow(event) {
    event.accepted = true
    if (window.hasValidSnippets) {
        window.debugLog("⬇️ Down arrow delegated from search field to NavigationController")
        navigationController.moveDown()
    }
}

// Clean, scannable key bindings
Keys.onEscapePressed: handleEscapeKey
Keys.onUpPressed: handleUpArrow
Keys.onDownPressed: handleDownArrow
Keys.onReturnPressed: handleEnterKey  // From duplicate removal task
Keys.onEnterPressed: handleEnterKey   // From duplicate removal task
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.