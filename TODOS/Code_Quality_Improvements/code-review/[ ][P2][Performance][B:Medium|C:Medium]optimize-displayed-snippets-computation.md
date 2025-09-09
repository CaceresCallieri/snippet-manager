# Optimize displayedSnippets Computation

## Priority: P2 | Type: Performance | Benefit: Medium | Complexity: Medium

## Problem Description

The `displayedSnippets` computed property in `OverlayWindow.qml` performs expensive filtering and array slicing operations on every binding evaluation, including when only navigation state changes. This causes unnecessary recomputation of the same filtered results, impacting performance especially with larger snippet collections.

**Performance Issues**:
- Filtering entire source array on every navigation change
- Redundant `highlightSearchTerm()` calls for unchanged search terms
- Multiple array operations (filter, slice, map) in single binding
- Binding triggered by navigation state changes that don't affect filter results

**Current Behavior**:
- Navigation up/down triggers complete re-filtering
- Same search results computed multiple times
- Performance degrades with snippet collection size
- Unnecessary CPU usage during smooth navigation

## Implementation Plan

1. **Analyze current binding triggers** and identify unnecessary recomputations
2. **Extract search filtering logic** into separate cached property
3. **Create intermediate `filteredSnippets` property** that only recomputes on search changes
4. **Modify `displayedSnippets`** to only slice the cached filtered results
5. **Add performance monitoring** to verify optimization effectiveness
6. **Test with larger snippet collections** to measure improvement

## File Locations

- `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml` (lines 36-62)
  - Current `displayedSnippets` property with filtering and highlighting
  - Complex binding that triggers on multiple state changes

## Success Criteria

- Filtering only occurs when search text changes
- Navigation changes only trigger array slicing, not filtering
- Measurable performance improvement with larger snippet collections
- No functional regression in search or navigation behavior
- Cleaner separation between filtering and display logic
- Reduced CPU usage during navigation operations

## Dependencies

None - This is a standalone performance optimization.

## Code Examples

**Current Implementation (Inefficient)**:
```javascript
readonly property var displayedSnippets: {
    // ❌ PROBLEM: Entire filtering process runs on every binding evaluation
    const searchActive = searchInput?.text?.length > 0
    let itemsToDisplay = []
    
    if (searchActive) {
        const searchTerm = searchInput.text.toLowerCase()
        itemsToDisplay = filteredSnippets.filter(snippet => {
            const titleMatch = snippet.title.toLowerCase().includes(searchTerm)
            const contentMatch = snippet.content.toLowerCase().includes(searchTerm)
            return titleMatch || contentMatch
        })
    } else {
        itemsToDisplay = sourceSnippets
    }
    
    // Array slicing and highlighting also recomputed unnecessarily
    const windowStart = navigationController.visibleRangeStartIndex
    const windowEnd = Math.min(windowStart + Constants.maxVisibleSnippets, itemsToDisplay.length)
    return itemsToDisplay.slice(windowStart, windowEnd).map(snippet => ({
        title: searchActive ? highlightSearchTerm(snippet.title, searchInput.text.trim()) : snippet.title,
        content: snippet.content,
        originalTitle: snippet.title
    }))
}
```

**Optimized Implementation (Efficient)**:
```javascript
// Stage 1: Cache filtered results (only recomputes when search changes)
readonly property var filteredSnippets: {
    if (!searchInput || !searchInput.text || searchInput.text.length === 0) {
        return sourceSnippets
    }
    
    const searchTerm = searchInput.text.toLowerCase()
    return sourceSnippets.filter(snippet => {
        const titleMatch = snippet.title.toLowerCase().includes(searchTerm)
        const contentMatch = snippet.content.toLowerCase().includes(searchTerm)
        return titleMatch || contentMatch
    })
}

// Stage 2: Cache highlighted results (only recomputes when filteredSnippets or search changes)  
readonly property var highlightedSnippets: {
    const searchActive = searchInput?.text?.length > 0
    if (!searchActive) {
        return filteredSnippets.map(snippet => ({
            title: snippet.title,
            content: snippet.content,
            originalTitle: snippet.title
        }))
    }
    
    const searchTerm = searchInput.text.trim()
    return filteredSnippets.map(snippet => ({
        title: highlightSearchTerm(snippet.title, searchTerm),
        content: snippet.content,
        originalTitle: snippet.title
    }))
}

// Stage 3: Display window (only recomputes when navigation or highlighting changes)
readonly property var displayedSnippets: {
    const windowStart = navigationController.visibleRangeStartIndex
    const windowEnd = Math.min(windowStart + Constants.maxVisibleSnippets, highlightedSnippets.length)
    return highlightedSnippets.slice(windowStart, windowEnd)
}
```

**Performance Monitoring Addition**:
```javascript
// Optional: Add performance tracking
property int filteringCalculationCount: 0
property int displayCalculationCount: 0

onFilteredSnippetsChanged: {
    filteringCalculationCount++
    window.debugLog(`🔍 Filtering recalculated (${filteringCalculationCount} times) - ${filteredSnippets.length} results`)
}

onDisplayedSnippetsChanged: {
    displayCalculationCount++
    window.debugLog(`📊 Display window recalculated (${displayCalculationCount} times)`)
}
```

**Benefits of Optimization**:
1. **Reduced CPU Usage**: Filtering only when search term changes
2. **Faster Navigation**: Navigation only triggers lightweight array slicing
3. **Scalability**: Performance improves significantly with larger collections
4. **Cleaner Architecture**: Clear separation between filtering, highlighting, and display logic

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.