# Move Hardcoded Values to Constants

## Priority: P3 | Type: Enhancement | Benefit: Low | Complexity: Low

## Problem Description

While the codebase has a well-designed Constants system in `utils/Constants.qml`, some hardcoded values still exist scattered throughout the code. These magic numbers reduce maintainability and make it harder to adjust UI behavior consistently across the application.

**Hardcoded Values Found**:
- Character count thresholds (e.g., `parent.text.length > 50`)
- Timeout values in various components
- Array size limits and buffer values
- UI spacing that's not in Constants

**Issues**:
- Inconsistent configuration management
- Difficult to maintain consistent UI behavior
- Hard to adjust values during development/testing
- Unclear meaning of magic numbers without context

## Implementation Plan

1. **Search for hardcoded numeric values** across all QML files
2. **Identify values that should be configurable** vs implementation details
3. **Add appropriate constants** to `utils/Constants.qml`
4. **Replace hardcoded values** with Constants references
5. **Group related constants** logically in Constants.qml
6. **Document the purpose** of new constants

## File Locations

- `/home/jc/Dev/snippet-manager/utils/Constants.qml`
  - Add new constant definitions
- `/home/jc/Dev/snippet-manager/ui/OverlayWindow.qml`
  - Replace hardcoded values with Constants references
- Search all `.qml` files for numeric literals that should be constants

## Success Criteria

- All UI-related magic numbers moved to Constants.qml
- Consistent configuration approach across the codebase
- Improved maintainability for UI adjustments
- Clear documentation of what each constant controls
- No functional changes to application behavior

## Dependencies

None - This is a standalone code quality improvement.

## Code Examples

**Currently Hardcoded Values (Examples)**:
```javascript
// In OverlayWindow.qml - Character count threshold
visible: parent.text.length > 50  // ❌ Hardcoded threshold

// Search input length validation
validator: RegularExpressionValidator {
    regularExpression: new RegExp("^.{0,100}$")  // ❌ Hardcoded max length
}

// Focus retry attempts (if this pattern exists)
readonly property int maxAttempts: 3  // ❌ Should be in Constants
```

**After Moving to Constants**:
```javascript
// In utils/Constants.qml - Add new constants section
readonly property QtObject characterCount: QtObject {
    readonly property int warningThreshold: 50
    readonly property int displayThreshold: 50
}

readonly property QtObject validation: QtObject {
    readonly property int maxSearchLength: 100
    readonly property int maxTitleLength: 200
    readonly property int maxContentLength: 10000
}

readonly property QtObject focus: QtObject {
    readonly property int maxRetryAttempts: 3
    readonly property int retryIntervalMs: 500
}
```

```javascript
// In OverlayWindow.qml - Use Constants references
visible: parent.text.length > Constants.characterCount.displayThreshold

validator: RegularExpressionValidator {
    regularExpression: new RegExp("^.{0," + Constants.validation.maxSearchLength + "}$")
}
```

**Search Commands to Find Hardcoded Values**:
```bash
# Find potential hardcoded numbers (filter out obvious ones like 0, 1, 2)
grep -r "[^a-zA-Z0-9_][3-9][0-9]*\|[^a-zA-Z0-9_][1-9][0-9][0-9]" --include="*.qml" . 

# Look for specific patterns that are often hardcoded
grep -r "length > [0-9]\|timeout.*[0-9]\|interval.*[0-9]" --include="*.qml" .
```

**Constants Organization**:
```javascript
// Group related constants logically in Constants.qml
readonly property QtObject ui: QtObject {
    // UI layout constants (already exist)
}

readonly property QtObject search: QtObject {
    // Search-related constants (already exist)
}

readonly property QtObject validation: QtObject {
    readonly property int maxSearchLength: 100
    readonly property int maxTitleLength: 200
    readonly property int maxContentLength: 10000
    readonly property int characterCountThreshold: 50
}

readonly property QtObject performance: QtObject {
    readonly property int focusRetryAttempts: 3
    readonly property int focusTimeoutMs: 500
    readonly property int injectionTimeoutMs: 2000
}
```

**Benefits of Moving to Constants**:
1. **Centralized Configuration**: All adjustable values in one place
2. **Better Documentation**: Constants can have descriptive names and comments
3. **Easier Testing**: Adjust behavior for testing without code changes
4. **Consistency**: Ensures related values stay synchronized
5. **Maintainability**: Clear separation between logic and configuration

## Alternative Approach - Component-Specific Constants

For values that are truly component-specific and unlikely to be reused:

```javascript
// Keep component-specific constants as local readonly properties
readonly property int maxDisplayItems: 5  // Component-specific limit
readonly property int retryCount: 3       // Local retry behavior
```

Only move values to global Constants if they:
- Are used in multiple components
- Represent UI/UX decisions that might need adjustment
- Are part of the overall design system

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.