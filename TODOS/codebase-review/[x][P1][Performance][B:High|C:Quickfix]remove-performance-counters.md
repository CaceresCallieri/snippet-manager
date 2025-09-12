# Remove Development-Only Performance Counters

## Priority: P1 | Type: Performance | Benefit: High | Complexity: Quickfix

## Problem Description

Three performance monitoring counters (`filteringCalculationCount`, `highlightingCalculationCount`, `displayCalculationCount`) and their change handlers provide no user value and consume memory/CPU cycles. These were added for development monitoring but serve no purpose in production code.

## Implementation Plan

1. Remove the three counter properties from OverlayWindow.qml
2. Remove the corresponding change handlers (`onFilteredSnippetsChanged`, `onHighlightedSnippetsChanged`, `onDisplayedSnippetsChanged`)
3. Remove any debug logging related to these counters

## File Locations

- `ui/OverlayWindow.qml` lines 115-137
- Counter properties: lines 123-125
- Change handlers: lines 127-137

## Success Criteria

- All performance counter properties removed
- All counter change handlers removed
- Application loads and functions normally
- Memory usage slightly reduced (measurable in debug tools)

## Dependencies

None

## Code Examples

**Current Code (to be removed):**
```qml
property int filteringCalculationCount: 0
property int highlightingCalculationCount: 0  
property int displayCalculationCount: 0

onFilteredSnippetsChanged: {
    filteringCalculationCount++
    if (debugLog) {
        debugLog(`📊 Filtering calculation #${filteringCalculationCount}: ${filteredSnippets.length} results`)
    }
}
```

**After Removal:**
Remove all above code completely.

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.