# Add Input Validation for Snippets

## Priority: P1 (Critical)
## Type: FIX
## Complexity: MEDIUM

## Problem
No validation of snippet data structure or content, allowing malicious or malformed data to crash the application.

## Current Issues
- No validation that snippets have required `title` and `content` properties
- No length limits on snippet content
- No sanitization of snippet data
- Malformed JSON can break navigation

## Solution
Add comprehensive validation in loadSnippets function:

```javascript
function validateSnippet(snippet, index) {
    if (!snippet || typeof snippet !== 'object') {
        console.warn(`Snippet ${index}: Invalid object`)
        return false
    }
    
    if (!snippet.title || typeof snippet.title !== 'string') {
        console.warn(`Snippet ${index}: Missing or invalid title`)
        return false
    }
    
    if (!snippet.content || typeof snippet.content !== 'string') {
        console.warn(`Snippet ${index}: Missing or invalid content`)
        return false
    }
    
    if (snippet.content.length > 10000) {
        console.warn(`Snippet ${index}: Content too long (${snippet.content.length} chars)`)
        return false
    }
    
    return true
}

// In loadSnippets:
const validSnippets = parsed.filter((snippet, index) => validateSnippet(snippet, index))
root.snippets = validSnippets
```

## Impact
- **Before**: Malformed data can crash app or inject malicious content
- **After**: Only valid, safe snippets are loaded

## Files to Change
- `/shell.qml` loadSnippets function

## Testing
1. Test with missing title/content fields
2. Test with extremely long content
3. Test with non-string values
4. Test with completely malformed JSON