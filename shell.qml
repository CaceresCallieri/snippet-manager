import QtQuick
import Quickshell
import Quickshell.Hyprland
import "ui" as UI
import "utils"

ShellRoot {
    id: root
    
    property bool isOverlayVisible: true
    // Debug mode toggle - change this to true/false as needed
    property bool isDebugLoggingEnabled: true
    property var loadedValidSnippets: []
    
    // Notification throttling - tracks count per unique notification
    property var notificationCounts: ({})
    
    /**
     * Conditionally logs debug messages with emoji markers
     * Only outputs when debug mode is enabled to keep production output clean.
     * 
     * @param {string} message - Debug message to log (should include emoji marker for consistency)
     * 
     * Side effects:
     * - Logs message to console only if isDebugLoggingEnabled is true
     * - No output in production mode
     */
    function debugLog(message) {
        if (isDebugLoggingEnabled) {
            console.log(message)
        }
    }
    
    /**
     * Sends desktop notifications to user via notify-send command with throttling
     * Used for critical errors, warnings, and status updates that user needs to see.
     * Implements simple counter-based throttling to prevent notification spam.
     * 
     * @param {string} title - Notification title (appears in notification header)
     * @param {string} message - Notification message body
     * @param {string} urgency - Urgency level: "low", "normal", or "critical" (default: "normal")
     * 
     * Throttling behavior:
     * - Critical notifications: Always sent (no throttling for important errors)
     * - Normal/Low notifications: Limited to 2 instances per unique title+message
     * - Prevents notification spam during repeated error conditions
     * 
     * Side effects:
     * - Executes notify-send command via Quickshell.execDetached
     * - Updates notificationCounts tracking object
     * - Logs error to console if notification sending fails
     * - No-op if notify-send command is not available on system
     */
    function notifyUser(title, message, urgency = "normal") {
        // Create unique key for this notification
        const notificationKey = title + "|" + message
        
        // Always allow critical notifications (important errors should never be suppressed)
        if (urgency !== "critical") {
            // Track count for non-critical notifications
            notificationCounts[notificationKey] = (notificationCounts[notificationKey] || 0) + 1
            
            // Throttle after 2 instances of the same notification
            if (notificationCounts[notificationKey] > 2) {
                root.debugLog(`🔇 Notification throttled (${notificationCounts[notificationKey]}x): ${title} - ${message}`)
                return
            }
        }
        
        try {
            const command = ["notify-send", "-u", urgency, title, message]
            Quickshell.execDetached(command)
            root.debugLog(`🔔 Notification sent: ${title} - ${message} (urgency: ${urgency})`)
        } catch (error) {
            console.error("❌ Failed to send notification:", error)
        }
    }
    
    /**
     * Fast validation for snippet data before text injection
     * Delegates to unified Validation.qml singleton for consistency.
     * 
     * @param {Object} snippet - Snippet object to validate
     * @returns {boolean} True if snippet has valid structure and properties
     */
    function validateSnippetData(snippet) {
        const isValid = Validation.isValidSnippetStructure(snippet)
        if (!isValid) {
            console.error("❌ Snippet data validation failed")
        }
        return isValid
    }
    
    /**
     * Comprehensive multi-level validation for snippet objects during data loading
     * Delegates to unified Validation.qml singleton for consistency.
     * 
     * @param {Object} snippet - Snippet object from JSON file to validate
     * @param {number} index - Array index for detailed error reporting
     * @returns {boolean} True if snippet passes all validation levels
     */
    function validateSnippet(snippet, index) {
        return Validation.isValidSnippet(snippet, index)
    }
    
    /**
     * Loads snippet data from JSON file with comprehensive error handling
     * Performs XMLHttpRequest to load data/snippets.json, validates all entries,
     * and gracefully handles various failure scenarios.
     * 
     * Expected JSON format: Array of objects with {title: string, content: string}
     * 
     * Data flow:
     * 1. XMLHttpRequest loads data/snippets.json via Qt.resolvedUrl
     * 2. JSON.parse converts response to JavaScript objects
     * 3. Array validation ensures top-level structure is correct
     * 4. validateSnippet filters out invalid entries
     * 5. Sets loadedValidSnippets to filtered results (empty array if none valid)
     * 
     * Side effects:
     * - Sets root.loadedValidSnippets to filtered snippet array
     * - Logs comprehensive status information and error details
     * - Provides graceful degradation (empty array) for all failure modes
     * - Triggers UI empty state display when no valid snippets found
     * 
     * Error handling:
     * - File not found: logs error, sets empty array
     * - Parse errors: logs JSON syntax issues, sets empty array  
     * - Type errors: logs expected vs actual structure, sets empty array
     * - Validation failures: filters out invalid snippets, logs counts
     */
    function loadSnippets() {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        const parsed = JSON.parse(xhr.responseText)
                        if (Array.isArray(parsed)) {
                            // Apply validation with filtering for graceful degradation
                            const validSnippets = parsed.filter((snippet, index) => Validation.isValidSnippet(snippet, index))
                            
                            if (validSnippets.length === 0) {
                                console.warn("⚠️ No valid snippets found after validation")
                                if (parsed.length > 0) {
                                    console.warn(`⚠️ All ${parsed.length} snippets were filtered out due to validation errors`)
                                    root.notifyUser("Snippet Manager", 
                                                  `All ${parsed.length} snippets failed validation - check data/snippets.json format`, 
                                                  "normal")
                                } else {
                                    root.notifyUser("Snippet Manager", 
                                                  "No snippets found - add snippets to data/snippets.json to get started", 
                                                  "low")
                                }
                                root.loadedValidSnippets = [] // Keep clean empty array - UI will handle empty state
                            } else {
                                root.loadedValidSnippets = validSnippets
                                root.debugLog(`✅ Validated ${validSnippets.length} of ${parsed.length} snippets from JSON file`)
                                if (validSnippets.length < parsed.length) {
                                    console.warn(`⚠️ ${parsed.length - validSnippets.length} invalid snippets were filtered out`)
                                }
                                root.debugLog("🔍 Valid snippets loaded: " + JSON.stringify(root.loadedValidSnippets, null, 2))
                            }
                        } else {
                            console.error("❌ Invalid JSON: expected array, got " + typeof parsed)
                            root.notifyUser("Snippet Manager Error",
                                          `Invalid JSON format: expected array, got ${typeof parsed}`,
                                          "critical")
                            root.loadedValidSnippets = []
                        }
                    } catch (e) {
                        console.error("❌ Failed to parse snippets JSON: " + e.message)
                        root.notifyUser("Snippet Manager Error",
                                      `Invalid JSON in snippets.json: ${e.message}`,
                                      "critical")
                        root.loadedValidSnippets = []
                    }
                } else {
                    console.error("❌ Failed to load snippets file. Status: " + xhr.status)
                    root.notifyUser("Snippet Manager Error", 
                                  `Failed to load snippets.json (Status: ${xhr.status})`, 
                                  "critical")
                    root.loadedValidSnippets = []
                }
            }
        }
        xhr.open("GET", Qt.resolvedUrl("data/snippets.json"))
        xhr.send()
    }
    
    GlobalShortcut {
        name: "show-snippet-manager"
        description: "Show snippet manager overlay"
        
        onPressed: {
            root.debugLog("GlobalShortcut pressed - toggling overlay")
            root.isOverlayVisible = !root.isOverlayVisible
        }
    }
    
    // Detached script approach - no complex timers needed!
    
    // All injection logic moved to detached script - much simpler!
    
    // Window capture no longer needed for wtype approach
    
    // Use LazyLoader for memory efficiency when overlay isn't shown
    LazyLoader {
        active: root.isOverlayVisible
        
        UI.OverlayWindow {
            sourceSnippets: root.loadedValidSnippets
            debugLog: root.debugLog
            
            // Pass notification function for UI error handling
            property var notifyUser: root.notifyUser
            
            onSnippetSelected: function(snippet) {
                root.debugLog("📋 Selected snippet: " + snippet.title)
                
                // Validate snippet data before processing
                if (!Validation.isValidSnippetStructure(snippet)) {
                    console.error("❌ Invalid snippet data - cannot dispatch event")
                    root.notifyUser("Snippet Manager Error", "Invalid snippet data - event dispatch failed", "critical")
                    Qt.quit()
                    return
                }
                
                try {
                    // Single snippet - dispatch single snippet event
                    root.debugLog("🚀 Dispatching single snippet event...")
                    const eventData = "SNIPPET_SELECTED:" + snippet.title
                    var command = ["hyprctl", "dispatch", "event", eventData]
                    root.debugLog("🔧 Dispatching event: " + eventData)
                    
                    Quickshell.execDetached(command)
                    root.debugLog("✅ Single snippet event dispatched successfully")
                } catch (error) {
                    console.error("❌ Failed to dispatch Hyprland event:", error)
                    root.notifyUser("Snippet Manager Error", 
                                  "Failed to dispatch event: " + error.message, 
                                  "critical")
                    
                    // TODO: Fallback to direct injection if event dispatch fails
                    // For now, we exit gracefully to prevent hanging UI
                }
                
                // Exit immediately - wrapper will handle injection via event
                Qt.quit()
            }
            
            onCombineSnippets: function(titles) {
                root.debugLog("🔗 Combining snippets: " + titles.join(", "))
                
                try {
                    // Dispatch combined snippets event with comma-separated titles
                    const titlesString = titles.join(",")
                    const eventData = "COMBINED_SNIPPETS_SELECTED:" + titlesString
                    var command = ["hyprctl", "dispatch", "event", eventData]
                    root.debugLog("🔧 Dispatching combined event: " + eventData)
                    
                    Quickshell.execDetached(command)
                    root.debugLog("✅ Combined snippets event dispatched successfully")
                } catch (error) {
                    console.error("❌ Failed to dispatch combined snippets event:", error)
                    root.notifyUser("Snippet Manager Error", 
                                  "Failed to dispatch combined event: " + error.message, 
                                  "critical")
                }
                
                // Exit immediately - wrapper will handle injection via event
                Qt.quit()
            }
            
            onDismissed: {
                root.debugLog("❌ Snippet manager dismissed")
                
                try {
                    // Send cancellation event to wrapper
                    Quickshell.execDetached(["hyprctl", "dispatch", "event", "SNIPPET_CANCELLED"])
                    root.debugLog("✅ Cancellation event dispatched")
                } catch (error) {
                    console.error("❌ Failed to dispatch cancellation event:", error)
                    // Don't show notification for cancellation failures - just exit
                }
                
                Qt.quit()
            }
        }
    }
    
    // Focus management no longer needed with detached approach!
    
    Component.onCompleted: {
        root.debugLog("📂 Loading snippets from JSON file...")
        loadSnippets()
    }
}
