# Create Constants File for Magic Numbers

## Priority: P2 (High)
## Type: ENHANCEMENT
## Complexity: LOW

## Problem
Multiple hardcoded values scattered throughout the codebase make it hard to maintain and configure.

## Current Magic Numbers
```javascript
implicitHeight: 320         // OverlayWindow.qml:56
height: 35                  // OverlayWindow.qml:108  
maxDisplayed: 5            // OverlayWindow.qml:11
margins.top: screen.height / 6  // OverlayWindow.qml:52
sleep 0.25                 // inject-text.sh:9
wtype -s 5                 // inject-text.sh:13
```

## Solution
Create a constants file for centralized configuration:

```javascript
// Constants.qml
pragma Singleton
import QtQuick

QtObject {
    // UI Layout
    readonly property int overlayHeight: 320
    readonly property int snippetItemHeight: 35
    readonly property int maxVisibleSnippets: 5
    readonly property real overlayTopOffset: 1.0/6.0
    
    // Text Injection Timing
    readonly property int injectionDelayMs: 250
    readonly property int wtypeDelayMs: 5
    
    // Input Validation
    readonly property int maxSnippetLength: 10000
    
    // Performance
    readonly property int maxSnippetsToLoad: 1000
}
```

## Usage Example
```javascript
// Instead of:
maxDisplayed: 5

// Use:
maxDisplayed: Constants.maxVisibleSnippets
```

## Impact
- **Before**: Magic numbers scattered throughout codebase
- **After**: Centralized, documented configuration values

## Files to Change
- Create `/utils/Constants.qml`
- Update `/ui/OverlayWindow.qml`
- Update `/shell.qml`
- Update `/inject-text.sh` (add comment references)

## Testing
1. Verify all magic numbers are replaced
2. Test changing constants affects behavior correctly
3. Ensure no hardcoded values remain