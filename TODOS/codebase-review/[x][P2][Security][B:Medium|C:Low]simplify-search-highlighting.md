# Simplify Search Highlighting Security

## Priority: P2 | Type: Security | Benefit: Medium | Complexity: Low

## Problem Description

The current search highlighting function has complex regex-based logic that could potentially have edge cases or security vulnerabilities. The complexity makes it difficult to audit for HTML injection issues and adds unnecessary cognitive overhead for a highlighting feature.

## Implementation Plan

1. Analyze current `highlightSearchTerm()` function complexity
2. Implement simpler string-based highlighting approach
3. Ensure HTML escaping is properly applied
4. Test highlighting with edge cases (special characters, empty strings, etc.)
5. Verify no regression in highlighting functionality

## File Locations

- `ui/OverlayWindow.qml` lines 568-611
- Function: `highlightSearchTerm()`
- Related: `escapeHtml()` function

## Success Criteria

- Simplified highlighting logic without complex regex
- All HTML injection risks eliminated
- Highlighting works correctly for normal search terms
- Edge cases handled gracefully (no crashes or broken display)

## Dependencies

None

## Code Examples

**Current Complex Approach:**
```javascript
function highlightSearchTerm(text, searchTerm) {
    if (!searchTerm || searchTerm.length === 0) {
        return escapeHtml(text)
    }
    
    try {
        const escapedText = escapeHtml(text)
        const escapedSearchTerm = escapeHtml(searchTerm.trim())
        
        if (escapedSearchTerm.length === 0) {
            return escapedText
        }
        
        // Complex regex pattern matching...
        const regex = new RegExp(`(${escapedSearchTerm.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi')
        
        return escapedText.replace(regex, function(match) {
            return `<span style="color: ${Constants.search.matchHighlightTextColor};">${match}</span>`
        })
    } catch (error) {
        console.error("Error in highlightSearchTerm:", error)
        return escapeHtml(text)
    }
}
```

**Proposed Simplified Approach:**
```javascript
function highlightSearchTerm(text, searchTerm) {
    if (!searchTerm || searchTerm.trim().length === 0) {
        return escapeHtml(text)
    }
    
    const escapedText = escapeHtml(text)
    const escapedTerm = escapeHtml(searchTerm.trim())
    
    // Simple case-insensitive split and join approach
    const lowerText = escapedText.toLowerCase()
    const lowerTerm = escapedTerm.toLowerCase()
    
    if (!lowerText.includes(lowerTerm)) {
        return escapedText
    }
    
    // Split by search term and rejoin with highlighting
    const parts = []
    let startIndex = 0
    let searchIndex = lowerText.indexOf(lowerTerm, startIndex)
    
    while (searchIndex !== -1) {
        // Add text before match
        if (searchIndex > startIndex) {
            parts.push(escapedText.substring(startIndex, searchIndex))
        }
        
        // Add highlighted match
        const matchText = escapedText.substring(searchIndex, searchIndex + escapedTerm.length)
        parts.push(`<span style="color: ${Constants.search.matchHighlightTextColor};">${matchText}</span>`)
        
        startIndex = searchIndex + escapedTerm.length
        searchIndex = lowerText.indexOf(lowerTerm, startIndex)
    }
    
    // Add remaining text
    if (startIndex < escapedText.length) {
        parts.push(escapedText.substring(startIndex))
    }
    
    return parts.join('')
}
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.