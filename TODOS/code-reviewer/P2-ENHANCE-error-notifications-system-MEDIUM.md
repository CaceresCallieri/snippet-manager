# Implement Comprehensive Error Notifications System

## Priority: P2 (High)
## Type: ENHANCE
## Complexity: MEDIUM

## Problem

Users don't receive feedback when critical errors occur (file system errors, JSON parsing failures, empty snippets), making troubleshooting difficult and resulting in poor user experience.

## Current Missing Scenarios

- JSON file doesn't exist or can't be read
- JSON parsing failures (malformed syntax)
- All snippets fail validation (empty result)
- File system permission errors
- Network/file system errors during loading
- Script execution failures (inject-text.sh)

## Issues

- Silent failures confuse users
- No indication of configuration problems
- Debugging requires checking console logs manually
- Users may not realize why snippet manager appears empty

## Solution

Implement desktop notification system using `notify-send` for all critical error states:

```javascript
// In shell.qml - Add notification helper
function notifyUser(title, message, urgency = "normal") {
    const command = ["notify-send", "-u", urgency, title, message]
    Quickshell.execDetached(command)
}

// Critical error notifications
xhr.onreadystatechange = function() {
    if (xhr.readyState === XMLHttpRequest.DONE) {
        if (xhr.status === 200) {
            // ... existing parsing logic
        } else {
            console.error("❌ Failed to load snippets file. Status: " + xhr.status)
            notifyUser("Snippet Manager Error", 
                      "Failed to load snippets.json (Status: " + xhr.status + ")", 
                      "critical")
            root.snippets = []
        }
    }
}

// JSON parsing error notification
try {
    const parsed = JSON.parse(xhr.responseText)
    // ... validation logic
} catch (e) {
    console.error("❌ Failed to parse snippets JSON: " + e.message)
    notifyUser("Snippet Manager Error", 
              "Invalid JSON in snippets.json: " + e.message, 
              "critical")
    root.snippets = []
}

// Empty snippets warning
if (validSnippets.length === 0) {
    console.warn("⚠️ No valid snippets found")
    notifyUser("Snippet Manager", 
              "No snippets found - check data/snippets.json", 
              "low")
    // ... fallback logic
}
```

## Notification Categories

### Critical (urgency="critical")
- File system errors (404, permissions)
- JSON parsing failures
- Script execution failures

### Normal (urgency="normal")  
- Validation warnings
- Configuration issues
- Missing optional resources

### Low (urgency="low")
- Empty snippets (with fallback)
- Informational messages
- Successful recovery operations

## Impact

- **Before**: Silent failures, user confusion, difficult debugging
- **After**: Clear error feedback, better UX, easier troubleshooting

## Files to Change

- `/shell.qml` - Add notifyUser() function and error notifications
- `/ui/OverlayWindow.qml` - Add notification calls for UI errors
- `/inject-text.sh` - Consider notification for injection failures

## Testing

1. Test with missing snippets.json file
2. Test with malformed JSON syntax  
3. Test with empty JSON array
4. Test with all-invalid snippets
5. Test with file permission errors
6. Verify notification urgency levels work correctly
7. Test notification doesn't block application startup

## Dependencies

- `notify-send` command (standard on most Linux desktops)
- Desktop notification daemon (usually pre-installed)

## Future Enhancements

- Notification action buttons (e.g., "Open snippets.json")
- Notification grouping to avoid spam
- User preference for notification levels
- Integration with system logs