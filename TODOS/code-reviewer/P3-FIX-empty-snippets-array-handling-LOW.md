# Handle Empty Snippets Array Gracefully

## Priority: P3 (Medium)
## Type: FIX
## Complexity: LOW

## Problem
The application doesn't gracefully handle cases where no snippets are loaded or the JSON file is empty.

## Current Missing Scenarios
- Empty JSON array `[]`
- JSON file doesn't exist
- All snippets fail validation
- Network/file system errors during loading

## Issues
- Navigation logic assumes snippets exist
- UI shows empty overlay without explanation
- No user feedback when no snippets available
- Potential divide-by-zero in navigation calculations

## Solution
Add empty state handling throughout:

```javascript
// In shell.qml loadSnippets
if (validSnippets.length === 0) {
    console.warn("⚠️ No valid snippets found")
    root.snippets = [{
        title: "No snippets available",
        content: "Add snippets to data/snippets.json to get started"
    }]
} else {
    root.snippets = validSnippets
}
```

```javascript
// In OverlayWindow.qml
property bool hasSnippets: snippets.length > 0

// Show different UI for empty state
Text {
    visible: !hasSnippets
    text: "No snippets available\nAdd snippets to data/snippets.json"
    color: "orange"
    horizontalAlignment: Text.AlignHCenter
}

// Only show navigation when snippets exist
Column {
    visible: hasSnippets
    // ... existing snippet list
}
```

## Navigation Safety
```javascript
// Protect all navigation calculations
readonly property var displayedSnippets: {
    if (snippets.length === 0) return []
    // ... existing logic
}

// Protect key navigation
case Qt.Key_Enter:
    if (snippets.length > 0 && window.globalIndex >= 0 && window.globalIndex < snippets.length) {
        // ... existing selection logic
    } else {
        debugLog("❌ Cannot select - no valid snippets")
    }
```

## Impact
- **Before**: Crashes or confusing empty overlay
- **After**: Clear feedback and graceful handling of no-snippets case

## Files to Change
- `/shell.qml` - Add empty state fallback
- `/ui/OverlayWindow.qml` - Add empty state UI
- Navigation logic - Add bounds protection

## Testing
1. Test with empty data/snippets.json
2. Test with missing data/snippets.json
3. Test with all-invalid snippets
4. Verify UI shows helpful message
5. Test navigation doesn't crash