# Implement Notification Throttling

## Priority: P3 | Type: Enhancement | Benefit: Low | Complexity: Low

## Problem Description

The current notification system could potentially spam users with identical notifications for minor issues. If validation fails repeatedly or errors occur in quick succession, users could receive multiple duplicate notifications that create a poor user experience.

## Implementation Plan

1. Add notification throttling mechanism to `shell.qml`
2. Track recent notifications by title+message combination
3. Implement 30-second cooldown for identical notifications
4. Test with scenarios that could cause notification spam
5. Ensure important notifications are never blocked inappropriately

## File Locations

- `shell.qml` - `notifyUser()` function around line 44
- Any files that call `notifyUser()` for testing

## Success Criteria

- Identical notifications throttled to max 1 per 30 seconds
- Important notifications still get through appropriately
- No memory leaks from notification tracking
- User experience improved during error conditions

## Dependencies

None

## Code Examples

**Current Unthrottled Approach:**
```javascript
function notifyUser(title, message, urgency = "normal") {
    try {
        const command = ["notify-send", "-u", urgency, title, message]
        Quickshell.execDetached(command)
    } catch (error) {
        console.error("❌ Failed to send notification:", error)
    }
}
```

**Proposed Throttled Approach:**
```javascript
property var lastNotifications: ({})

function notifyUser(title, message, urgency = "normal") {
    const notificationKey = title + "|" + message
    const now = Date.now()
    
    // Check if this notification was recently sent
    if (lastNotifications[notificationKey]) {
        const timeSinceLastNotification = now - lastNotifications[notificationKey]
        if (timeSinceLastNotification < 30000) { // 30 seconds
            return // Skip duplicate notification
        }
    }
    
    // Record this notification
    lastNotifications[notificationKey] = now
    
    // Clean old entries (prevent memory leak)
    for (const key in lastNotifications) {
        if (now - lastNotifications[key] > 60000) { // Clean entries older than 1 minute
            delete lastNotifications[key]
        }
    }
    
    try {
        const command = ["notify-send", "-u", urgency, title, message]
        Quickshell.execDetached(command)
    } catch (error) {
        console.error("❌ Failed to send notification:", error)
    }
}
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.