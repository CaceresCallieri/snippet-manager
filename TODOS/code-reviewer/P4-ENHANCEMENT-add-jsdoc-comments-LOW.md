# Add JSDoc Comments for Complex Functions

## Priority: P4 (Low)
## Type: ENHANCEMENT
## Complexity: LOW

## Problem
Complex functions lack documentation explaining their purpose, parameters, and behavior, making the code harder to maintain.

## Functions Needing Documentation

### Navigation Functions
```javascript
/**
 * Recalculates which snippets should be displayed in the current window
 * @returns {Array} Array of snippet objects to display (max 5 items)
 */
readonly property var displayedSnippets: {
    // Implementation
}

/**
 * Handles keyboard navigation up, with window scrolling and wrap-around
 * Moves selection up within visible window, scrolls window if at top,
 * or wraps to bottom of list if already at absolute top
 */
function navigateUp() {
    // Implementation
}
```

### Data Loading Functions  
```javascript
/**
 * Loads snippets from JSON file with error handling and validation
 * Sets root.snippets to loaded data or empty array on failure
 * Logs detailed information about loading process
 */
function loadSnippets() {
    // Implementation
}

/**
 * Validates a snippet object has required properties and safe content
 * @param {Object} snippet - Snippet object to validate
 * @param {number} index - Index for error reporting
 * @returns {boolean} True if snippet is valid and safe to use
 */
function validateSnippet(snippet, index) {
    // Implementation  
}
```

### UI State Functions
```javascript
/**
 * Logs debug message with emoji marker if debug mode is enabled
 * @param {string} message - Debug message to log
 */
function debugLog(message) {
    // Implementation
}

/**
 * Handles snippet selection and triggers text injection
 * Launches detached injection script and exits application
 * @param {Object} snippet - Selected snippet with title and content
 */
onSnippetSelected: function(snippet) {
    // Implementation
}
```

## Documentation Standards
- Use JSDoc format for consistency
- Document all parameters and return values
- Explain complex behavior and edge cases
- Include examples for non-obvious usage
- Document side effects (like Qt.quit())

## Complex Logic Examples
```javascript
/**
 * Calculates wrap-around navigation to bottom of list
 * 
 * When navigating up from the first item, this positions the window
 * and cursor to show the last items in the list. Handles edge cases
 * where total items is less than max display count.
 * 
 * Side effects:
 * - Sets windowStart to show last page of snippets
 * - Sets currentIndex to select the last item in window
 */
function wrapToBottom() {
    window.windowStart = Math.max(0, snippets.length - window.maxDisplayed)
    window.currentIndex = Math.min(window.maxDisplayed - 1, snippets.length - 1 - window.windowStart)
}
```

## Impact
- **Before**: Code behavior unclear without reading implementation
- **After**: Self-documenting code with clear contracts

## Files to Change
- `/shell.qml` - Document data loading and initialization functions
- `/ui/OverlayWindow.qml` - Document navigation and UI functions
- Focus on most complex or non-obvious functions first

## Testing
1. Ensure documentation matches actual behavior
2. Verify examples in comments work correctly
3. Update documentation if implementation changes