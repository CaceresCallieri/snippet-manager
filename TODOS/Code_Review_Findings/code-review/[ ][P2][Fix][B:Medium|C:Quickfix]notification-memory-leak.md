# Fix Notification Memory Leak

## Priority: P2 | Type: Fix | Benefit: Medium | Complexity: Quickfix

## Problem Description

The `notificationCounts` object in shell.qml grows indefinitely without cleanup, creating a memory leak in long-running sessions. Each unique notification title+message combination creates a permanent entry that is never removed, potentially consuming significant memory over time.

## Implementation Plan

1. Add maximum history limit for notification tracking (suggest 100 entries)
2. Implement FIFO cleanup when limit is exceeded
3. Add periodic cleanup logic to remove old notification entries
4. Test memory usage in long-running scenarios
5. Ensure notification throttling behavior remains unchanged

## File Locations

- `shell.qml:54-77` - `notifyUser()` function with growing `notificationCounts` object
- `shell.qml:16` - `notificationCounts` property declaration

## Success Criteria

- Memory usage remains bounded regardless of session length
- Notification throttling behavior unchanged for recent notifications
- Cleanup logic efficiently removes oldest entries when limit exceeded
- No performance impact on notification operations
- Testing shows stable memory usage over extended periods

## Dependencies

None

## Code Examples

**Current Memory Leak Implementation:**
```javascript
// In shell.qml - grows indefinitely
property var notificationCounts: ({})

function notifyUser(title, message, urgency = "normal") {
    const notificationKey = title + "|" + message
    
    if (urgency !== "critical") {
        // This grows forever - memory leak!
        notificationCounts[notificationKey] = (notificationCounts[notificationKey] || 0) + 1
        
        if (notificationCounts[notificationKey] > 2) {
            return
        }
    }
    
    // Send notification...
}
```

**Proposed Memory-Bounded Implementation:**
```javascript
// In shell.qml - with cleanup logic
property var notificationCounts: ({})
readonly property int maxNotificationHistory: 100

function notifyUser(title, message, urgency = "normal") {
    const notificationKey = title + "|" + message
    
    // Cleanup old entries if we have too many
    const keys = Object.keys(notificationCounts)
    if (keys.length > maxNotificationHistory) {
        // Remove oldest 20% of entries (simple FIFO cleanup)
        const entriesToRemove = Math.floor(maxNotificationHistory * 0.2)
        keys.slice(0, entriesToRemove).forEach(key => {
            delete notificationCounts[key]
        })
        debugLog(`🧹 Cleaned up ${entriesToRemove} old notification entries`)
    }
    
    // Always allow critical notifications
    if (urgency !== "critical") {
        notificationCounts[notificationKey] = (notificationCounts[notificationKey] || 0) + 1
        
        // Throttle after 2 instances of the same notification
        if (notificationCounts[notificationKey] > 2) {
            debugLog(`🔇 Notification throttled (${notificationCounts[notificationKey]}x): ${title} - ${message}`)
            return
        }
    }
    
    try {
        const command = ["notify-send", "-u", urgency, title, message]
        Quickshell.execDetached(command)
        debugLog(`🔔 Notification sent: ${title} - ${message} (urgency: ${urgency})`)
    } catch (error) {
        console.error("❌ Failed to send notification:", error)
    }
}
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.