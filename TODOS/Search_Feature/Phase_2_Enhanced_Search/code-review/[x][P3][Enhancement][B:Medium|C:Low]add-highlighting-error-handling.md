# Add Error Handling to Search Highlighting Function

## Priority: P3 | Type: Enhancement | Benefit: Medium | Complexity: Low

## Problem Description

The `highlightSearchTerm` function lacks error handling for edge cases that could cause the application to crash or behave unexpectedly. Currently, there's no protection against malformed regex patterns, null/undefined inputs, or JavaScript runtime errors during text processing.

**Potential Issues**:
- Malformed search terms could create invalid regex patterns
- Null or undefined text inputs could cause runtime errors
- Type coercion issues with non-string inputs
- Regex replace operations could fail silently

## Implementation Plan

1. **Add input validation for text and searchTerm parameters**
2. **Wrap regex operations in try-catch blocks**
3. **Add type checking for string inputs**
4. **Provide graceful fallbacks for error scenarios**
5. **Add debug logging for error cases**
6. **Test with various edge case inputs**

## File Locations

- `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml` (lines 274-283)
  - Function: `highlightSearchTerm(text, searchTerm)`

## Success Criteria

- Function handles null/undefined inputs gracefully
- Invalid regex patterns don't crash the application
- Non-string inputs are handled appropriately  
- Error cases are logged for debugging
- Search highlighting continues working in error scenarios
- No functional regressions for valid inputs

## Dependencies

[Depends-On: html-injection-vulnerability] - Error handling should be added after security fixes are implemented.

## Code Examples

**Current Implementation (No Error Handling)**:
```javascript
function highlightSearchTerm(text, searchTerm) {
    if (!searchTerm || searchTerm.length === 0) {
        return text  // ❌ Could be null/undefined
    }
    
    const escapedTerm = searchTerm.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')  // ❌ Could fail
    const regex = new RegExp(`(${escapedTerm})`, 'gi')  // ❌ Could throw
    
    return text.replace(regex, `<span style="color: ${Constants.search.matchHighlightTextColor};">$1</span>`)  // ❌ Could fail
}
```

**Proposed Robust Implementation**:
```javascript
/**
 * Highlights search term matches with comprehensive error handling
 * Provides graceful fallbacks for all error scenarios
 * 
 * @param {string} text - Original text to highlight (validated for type and existence)  
 * @param {string} searchTerm - Search term to highlight (validated for type and existence)
 * @returns {string} HTML-formatted text with highlighted matches, or safely escaped text on error
 * 
 * Error handling:
 * - Validates input types and existence
 * - Handles regex compilation errors
 * - Provides fallbacks for all failure modes
 * - Logs errors for debugging without crashing UI
 */
function highlightSearchTerm(text, searchTerm) {
    try {
        // Input validation
        if (!text || typeof text !== 'string') {
            window.debugLog("⚠️ Highlighting: Invalid text input")
            return ""
        }
        
        if (!searchTerm || typeof searchTerm !== 'string' || searchTerm.length === 0) {
            return escapeHtml(text)
        }
        
        // Sanitize inputs
        const escapedText = escapeHtml(text)
        const escapedTerm = escapeHtml(searchTerm)
        
        // Regex escaping with error handling
        let regexPattern
        try {
            regexPattern = escapedTerm.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
        } catch (error) {
            window.debugLog("⚠️ Highlighting: Regex escaping failed - " + error.message)
            return escapedText
        }
        
        if (regexPattern.length === 0) {
            return escapedText
        }
        
        // Regex compilation and replacement with error handling
        try {
            const regex = new RegExp(`(${regexPattern})`, 'gi')
            return escapedText.replace(regex, `<span style="color: ${Constants.search.matchHighlightTextColor};">$1</span>`)
        } catch (error) {
            window.debugLog("⚠️ Highlighting: Regex compilation/replacement failed - " + error.message)
            return escapedText
        }
        
    } catch (error) {
        console.warn("❌ Highlighting function failed:", error.message)
        // Ultimate fallback - return safely escaped text or empty string
        return (text && typeof text === 'string') ? escapeHtml(text) : ""
    }
}
```

**Edge Case Test Scenarios**:
```javascript
// Test cases to validate error handling:
// highlightSearchTerm(null, "test")           // Should return ""
// highlightSearchTerm(undefined, "test")      // Should return ""
// highlightSearchTerm("text", null)          // Should return "text" (escaped)
// highlightSearchTerm("text", undefined)     // Should return "text" (escaped)
// highlightSearchTerm(123, "test")           // Should return ""
// highlightSearchTerm("text", 123)           // Should return "text" (escaped)
// highlightSearchTerm("text", "[unclosed")   // Should handle malformed regex gracefully
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.