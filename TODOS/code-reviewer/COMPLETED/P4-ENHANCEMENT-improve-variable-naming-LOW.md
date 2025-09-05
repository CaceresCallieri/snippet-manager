# Improve Variable Naming Throughout Codebase

## Priority: P4 (Low)
## Type: ENHANCEMENT
## Complexity: LOW

## Problem
Several variables have unclear or ambiguous names that don't clearly communicate their purpose.

## Current Unclear Names

### OverlayWindow.qml
```javascript
// UNCLEAR NAMES
property int calculationCount: 0        // What kind of calculations?
property int windowStart: 0             // Window of what?
property int maxDisplayed: 5            // Max displayed what?
property var displayedSnippets          // Displayed where/how?

// BETTER NAMES
property int displayCalculationCount: 0
property int visibleSnippetsStartIndex: 0  
property int maxVisibleSnippets: 5
property var visibleSnippetWindow
```

### Shell.qml
```javascript
// UNCLEAR NAMES
property var snippets: []               // All snippets or filtered?
property bool shouldShowOverlay: true   // When/why should it show?

// BETTER NAMES  
property var loadedSnippets: []
property bool overlayVisible: true
```

### General Issues
- Single letter variables in loops could be more descriptive
- Generic names like `window` when there are multiple windows
- Inconsistent naming patterns between files

## Solution Examples

### Navigation Variables
```javascript
// Current
property int currentIndex: 0
property int windowStart: 0

// Improved
property int selectedSnippetIndex: 0
property int visibleRangeStartIndex: 0
```

### State Variables
```javascript
// Current
property bool shouldShowOverlay: true
property bool debugMode: true

// Improved
property bool isOverlayVisible: true
property bool debugLoggingEnabled: true
```

### Functions
```javascript
// Current
function debugLog(message) { }
function loadSnippets() { }

// Improved
function logDebugMessage(message) { }
function loadSnippetsFromJson() { }
```

## Impact
- **Before**: Code requires mental translation to understand purpose
- **After**: Self-documenting code that's immediately clear

## Files to Change
- `/ui/OverlayWindow.qml` - Rename navigation and display variables
- `/shell.qml` - Rename state and data variables
- All files - Review and improve unclear names

## Testing
1. Verify all renames compile correctly
2. Test functionality still works after renames
3. Review that new names are consistently used
4. Ensure no missed references to old names