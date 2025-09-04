# Fix Binding Loop in displayedSnippets

## Priority: P2 (High)
## Type: FIX
## Complexity: LOW

## Problem
The displayedSnippets property creates unnecessary recalculations due to modifying calculationCount within the binding.

## Problematic Code
```javascript
// OverlayWindow.qml:17-31
property var displayedSnippets: {
    Qt.callLater(function() { 
        calculationCount++  // This triggers the binding to recalculate
    })
    return snippets.slice(windowStart, end)
}
```

## Issues
- Performance overhead from unnecessary recalculations
- Potential binding loop warnings
- Debug counter mixed with production logic

## Solution
Separate the calculation from debug tracking:

```javascript
readonly property var displayedSnippets: {
    if (snippets.length === 0) return []
    const end = Math.min(windowStart + maxDisplayed, snippets.length)
    trackCalculation()  // Move tracking to separate function
    return snippets.slice(windowStart, end)
}

function trackCalculation() {
    calculationCount++
    if (debugMode) {
        console.log("📊 displayedSnippets recalculated (count: " + calculationCount + ")")
    }
}
```

## Impact
- **Before**: Unnecessary binding recalculations
- **After**: Clean, efficient property binding

## Files to Change
- `/ui/OverlayWindow.qml` lines 17-31

## Testing
1. Monitor QML binding warnings in console
2. Check performance with large snippet lists
3. Verify calculation count still works for debugging