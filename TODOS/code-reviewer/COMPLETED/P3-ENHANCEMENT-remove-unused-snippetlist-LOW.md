# Remove Unused SnippetList.qml File

## Priority: P3 (Medium)
## Type: ENHANCEMENT
## Complexity: LOW

## Problem
The SnippetList.qml file appears to be unused in the current implementation but remains in the codebase, creating confusion and maintenance burden.

## Analysis
- `ui/OverlayWindow.qml` implements snippet display directly with Column + Repeater
- `ui/SnippetList.qml` is not imported or referenced anywhere
- File contains ListView implementation that's not being used
- Creates confusion about which component is actually responsible for snippet display

## Current State
```javascript
// ui/OverlayWindow.qml uses this pattern:
Column {
    Repeater {
        model: window.displayedSnippets
        // Direct snippet item implementation
    }
}

// ui/SnippetList.qml contains unused ListView implementation
```

## Options

### Option 1: Remove Completely (Recommended)
If the file is truly unused, remove it to clean up codebase:
- Delete `/ui/SnippetList.qml`
- Update any references (none found currently)
- Clean up qmldir if needed

### Option 2: Document Purpose
If file is kept for future use, add clear documentation:
```javascript
// ui/SnippetList.qml
// FUTURE ENHANCEMENT: Alternative ListView-based implementation
// Currently unused - OverlayWindow.qml uses Column+Repeater instead
// Kept for potential performance improvements with large snippet lists
```

### Option 3: Integrate if Better
If ListView approach is superior, switch to using SnippetList.qml:
- Compare performance characteristics
- Evaluate maintainability
- Switch OverlayWindow.qml to use SnippetList component

## Recommendation
Remove the file unless there's a specific planned use case.

## Impact
- **Before**: Confusion about which component is used
- **After**: Clear, single implementation

## Files to Change
- Remove `/ui/SnippetList.qml` (most likely)
- Or document purpose clearly

## Testing
1. Verify removal doesn't break anything
2. Ensure no hidden imports or references
3. Test app still works correctly