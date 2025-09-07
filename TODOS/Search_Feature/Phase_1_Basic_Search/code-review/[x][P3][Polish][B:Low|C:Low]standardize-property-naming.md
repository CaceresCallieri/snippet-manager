# Standardize Property Naming Convention

## Priority: P3 | Type: Polish | Benefit: Low | Complexity: Low

## Problem Description

The search feature implementation uses inconsistent naming conventions across related properties, which could lead to confusion during maintenance and future development. The current naming mixes different patterns without a clear convention.

Current inconsistent naming:
- `snippets` (base data array)
- `filteredSnippets` (computed filtered array) 
- `hasValidSnippets` (boolean state based on filtered data)

This inconsistency makes the data flow relationships less clear and could cause confusion about which properties contain the "current" data state.

## Implementation Plan

1. Analyze current property usage throughout OverlayWindow.qml
2. Design consistent naming convention that clearly indicates data flow relationships
3. Update property names using systematic approach
4. Update all references to renamed properties
5. Test functionality to ensure no breaking changes
6. Update documentation to reflect new naming conventions

## File Locations

- **Primary**: `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml` (Lines 10, 35, 54)
  - Property declarations and usage throughout component
- **Secondary**: `/home/jc/Dev/snippet-manager/ui/NavigationController.qml`
  - May need updates if property bindings change

## Success Criteria

- [ ] Consistent naming pattern applied to all search-related properties
- [ ] Data flow relationships clear from property names
- [ ] No breaking changes - all functionality preserved
- [ ] Updated JSDoc documentation reflects new naming
- [ ] Future developers can easily understand data relationships

## Dependencies

- **Suggested After**: simplify-filtering-logic - Easier to rename during simplification

## Code Examples

**Current Implementation (Inconsistent Naming)**:
```qml
PanelWindow {
    property var snippets: []                    // Base data
    
    property var filteredSnippets: {             // Computed filtered data
        // filtering logic
    }
    
    property bool hasValidSnippets: filteredSnippets.length > 0  // State boolean
    
    NavigationController {
        snippets: window.filteredSnippets        // Uses filtered data
    }
}
```

**Proposed Implementation Option A (Source/Display Pattern)**:
```qml
PanelWindow {
    property var sourceSnippets: []              // Clear: original data source
    
    property var displayedSnippets: {            // Clear: what's currently shown
        // filtering logic
    }
    
    property bool hasSnippetsToDisplay: displayedSnippets.length > 0  // Clear intent
    
    NavigationController {
        snippets: window.displayedSnippets       // Uses displayed data
    }
}
```

**Proposed Implementation Option B (Raw/Filtered Pattern)**:
```qml
PanelWindow {
    property var rawSnippets: []                 // Clear: unprocessed data
    
    property var filteredSnippets: {             // Keep existing name (most used)
        // filtering logic  
    }
    
    property bool hasFilteredSnippets: filteredSnippets.length > 0  // Consistent prefix
    
    NavigationController {
        snippets: window.filteredSnippets        // No change needed
    }
}
```

**Recommended Approach (Option A - Source/Display)**:
- **Rationale**: "Source" and "Display" clearly indicate the data transformation flow
- **Benefits**: Intuitive for future developers, follows common UI patterns
- **Consistency**: All related properties follow same semantic pattern

**Property Mapping**:
- `snippets` → `sourceSnippets`
- `filteredSnippets` → `displayedSnippets` 
- `hasValidSnippets` → `hasSnippetsToDisplay`

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.