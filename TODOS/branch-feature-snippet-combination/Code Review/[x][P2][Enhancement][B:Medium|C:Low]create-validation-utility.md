# Create Unified Validation Utility

## Priority: P2 | Type: Enhancement | Benefit: Medium | Complexity: Low

## Problem Description

The same snippet validation logic is repeated in 4+ places across the codebase (`shell.qml`, `CombiningModeController.qml`, `SnippetCombiner.qml`, `OverlayWindow.qml`). This code duplication makes maintenance difficult and increases the risk of inconsistent validation behavior.

## Implementation Plan

1. Create new `utils/Validation.qml` singleton file
2. Move all validation functions to the singleton
3. Replace duplicated validation code with calls to the singleton
4. Update import statements across affected files
5. Test all validation scenarios to ensure consistency

## File Locations

- Create: `utils/Validation.qml` (new file)
- Update: `shell.qml` - `validateSnippet()`, `validateSnippetData()`
- Update: `ui/CombiningModeController.qml` - `validateSnippetForAddition()`
- Update: `ui/SnippetCombiner.qml` - validation functions
- Update: `ui/OverlayWindow.qml` - any validation calls

## Success Criteria

- Single source of truth for all validation logic
- All duplicate validation code removed
- All validation behavior remains consistent
- New `Validation.qml` singleton properly accessible across codebase

## Dependencies

None

## Code Examples

**New Validation Singleton:**
```qml
// utils/Validation.qml
pragma Singleton
import QtQuick

QtObject {
    readonly property int maxTitleLength: 200
    readonly property int maxContentLength: 10000
    
    function isValidSnippet(snippet) {
        return snippet && 
               typeof snippet === 'object' &&
               typeof snippet.title === 'string' &&
               typeof snippet.content === 'string' &&
               snippet.title.length <= maxTitleLength &&
               snippet.content.length <= maxContentLength
    }
    
    function isValidSnippetStructure(snippet) {
        return snippet && 
               typeof snippet === 'object' &&
               snippet.hasOwnProperty('title') && 
               snippet.hasOwnProperty('content') &&
               typeof snippet.title === 'string' &&
               typeof snippet.content === 'string'
    }
    
    function validateCombinedSize(size) {
        return size > 0 && size <= maxContentLength
    }
}
```

**Updated Usage:**
```qml
// In shell.qml
import "../utils"

function validateSnippet(snippet, index) {
    if (!Validation.isValidSnippet(snippet)) {
        console.warn(`Snippet ${index}: Failed validation`)
        return false
    }
    return true
}
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.