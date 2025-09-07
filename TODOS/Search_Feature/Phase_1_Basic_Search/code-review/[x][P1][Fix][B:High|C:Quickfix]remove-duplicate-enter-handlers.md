# Remove Duplicate Enter Key Handlers

## Priority: P1 | Type: Fix | Benefit: High | Complexity: Quickfix

## Problem Description

The search TextField implementation contains identical code duplicated between `Keys.onReturnPressed` and `Keys.onEnterPressed` handlers. This code duplication creates maintenance burden and risk of inconsistent behavior if only one handler is updated during future modifications.

Current state: 40+ lines of identical logic duplicated across both handlers, handling snippet selection validation and execution.

## Implementation Plan

1. Extract shared logic into a dedicated function `handleEnterKey(event)`
2. Replace both inline handlers with calls to the shared function
3. Ensure function maintains all existing validation and debug logging
4. Test keyboard functionality to confirm no behavior regression

## File Locations

- **Primary**: `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml` (Lines 260-284)
  - `Keys.onReturnPressed` handler - contains duplicated logic
  - `Keys.onEnterPressed` handler - contains identical duplicated logic

## Success Criteria

- [ ] Single shared function handles both Return and Enter key events
- [ ] Existing validation logic preserved (validateAndSelectSnippet call)
- [ ] Debug logging functionality maintained
- [ ] No behavior changes - both keys continue working identically
- [ ] Code reduction: ~20 lines eliminated through deduplication

## Dependencies

None - standalone code quality improvement

## Code Examples

**Current Implementation (Problematic)**:
```qml
Keys.onReturnPressed: function(event) {
    event.accepted = true
    if (window.hasValidSnippets && navigationController.visibleSnippetWindow.length > 0) {
        const selectedSnippet = navigationController.visibleSnippetWindow[navigationController.currentIndex]
        if (selectedSnippet) {
            window.debugLog("⌨️ Enter key pressed - selecting snippet: " + selectedSnippet.title)
            if (!window.validateAndSelectSnippet(selectedSnippet, "enter_key")) {
                window.debugLog("❌ Enter key validation failed")
            }
        }
    }
}

Keys.onEnterPressed: function(event) {
    // Identical code repeated - maintenance risk
    event.accepted = true
    if (window.hasValidSnippets && navigationController.visibleSnippetWindow.length > 0) {
        const selectedSnippet = navigationController.visibleSnippetWindow[navigationController.currentIndex]
        if (selectedSnippet) {
            window.debugLog("⌨️ Enter key pressed - selecting snippet: " + selectedSnippet.title)
            if (!window.validateAndSelectSnippet(selectedSnippet, "enter_key")) {
                window.debugLog("❌ Enter key validation failed")
            }
        }
    }
}
```

**Proposed Implementation (Solution)**:
```qml
function handleEnterKey(event) {
    event.accepted = true
    if (window.hasValidSnippets && navigationController.visibleSnippetWindow.length > 0) {
        const selectedSnippet = navigationController.visibleSnippetWindow[navigationController.currentIndex]
        if (selectedSnippet) {
            window.debugLog("⌨️ Enter key pressed - selecting snippet: " + selectedSnippet.title)
            if (!window.validateAndSelectSnippet(selectedSnippet, "enter_key")) {
                window.debugLog("❌ Enter key validation failed")
            }
        }
    }
}

Keys.onReturnPressed: handleEnterKey
Keys.onEnterPressed: handleEnterKey
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.