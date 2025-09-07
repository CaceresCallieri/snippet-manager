import QtQuick
import Quickshell
import Quickshell.Hyprland
import "ui" as UI

ShellRoot {
    id: root
    
    property bool isOverlayVisible: true
    // Debug mode toggle - change this to true/false as needed
    property bool isDebugLoggingEnabled: true
    property var loadedValidSnippets: []
    
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
     * Sends desktop notifications to user via notify-send command
     * Used for critical errors, warnings, and status updates that user needs to see.
     * 
     * @param {string} title - Notification title (appears in notification header)
     * @param {string} message - Notification message body
     * @param {string} urgency - Urgency level: "low", "normal", or "critical" (default: "normal")
     * 
     * Side effects:
     * - Executes notify-send command via Quickshell.execDetached
     * - Logs error to console if notification sending fails
     * - No-op if notify-send command is not available on system
     */
    function notifyUser(title, message, urgency = "normal") {
        try {
            const command = ["notify-send", "-u", urgency, title, message]
            Quickshell.execDetached(command)
        } catch (error) {
            console.error("❌ Failed to send notification:", error)
        }
    }
    
    /**
     * Fast validation for snippet data before text injection
     * Used as final safety check before processing user-selected snippets.
     * 
     * @param {Object} snippet - Snippet object to validate
     * @returns {boolean} True if snippet has valid structure and properties
     * 
     * Validation checks:
     * - Object existence and type
     * - Required properties (title, content) exist and are strings
     * 
     * Side effects:
     * - Logs detailed error messages for each validation failure
     * - Does NOT check content length limits (handled by validateSnippet)
     */
    function validateSnippetData(snippet) {
        if (!snippet) {
            console.error("❌ Snippet data is null or undefined")
            return false
        }
        
        if (typeof snippet !== 'object') {
            console.error("❌ Snippet data is not an object:", typeof snippet)
            return false
        }
        
        if (!snippet.hasOwnProperty('title') || typeof snippet.title !== 'string') {
            console.error("❌ Snippet missing valid title property")
            return false
        }
        
        if (!snippet.hasOwnProperty('content') || typeof snippet.content !== 'string') {
            console.error("❌ Snippet missing valid content property")
            return false
        }
        
        return true
    }
    
    /**
     * Comprehensive multi-level validation for snippet objects during data loading
     * Ensures only safe, well-formed snippets are displayed in the UI.
     * Consistent with security boundaries enforced by inject-text.sh.
     * 
     * @param {Object} snippet - Snippet object from JSON file to validate
     * @param {number} index - Array index for detailed error reporting
     * @returns {boolean} True if snippet passes all validation levels
     * 
     * Validation levels:
     * 1. Object structure - existence and type checking
     * 2. Required fields - title and content properties must exist
     * 3. Type validation - both properties must be strings
     * 4. Content limits - title ≤ 200 chars, content ≤ 10KB
     * 
     * Side effects:
     * - Logs warning messages for each validation failure with specific details
     * - Uses index parameter to identify problematic snippets in console output
     */
    function validateSnippet(snippet, index) {
        // Level 1: Object structure validation
        if (!snippet || typeof snippet !== 'object') {
            console.warn(`Snippet ${index}: Invalid object (${typeof snippet})`)
            return false
        }
        
        // Level 2: Required field validation
        if (!snippet.hasOwnProperty('title')) {
            console.warn(`Snippet ${index}: Missing title property`)
            return false
        }
        
        if (!snippet.hasOwnProperty('content')) {
            console.warn(`Snippet ${index}: Missing content property`)
            return false
        }
        
        // Level 3: Type validation
        if (typeof snippet.title !== 'string') {
            console.warn(`Snippet ${index}: Title must be string, got ${typeof snippet.title}`)
            return false
        }
        
        if (typeof snippet.content !== 'string') {
            console.warn(`Snippet ${index}: Content must be string, got ${typeof snippet.content}`)
            return false
        }
        
        // Level 4: Content limits (consistent with inject-text.sh)
        if (snippet.title.length > 200) {
            console.warn(`Snippet ${index}: Title too long (${snippet.title.length} chars, max 200)`)
            return false
        }
        
        if (snippet.content.length > 10000) {
            console.warn(`Snippet ${index}: Content too long (${snippet.content.length} chars, max 10KB)`)
            return false
        }
        
        return true
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
                            const validSnippets = parsed.filter((snippet, index) => root.validateSnippet(snippet, index))
                            
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
                                console.log(`✅ Validated ${validSnippets.length} of ${parsed.length} snippets from JSON file`)
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
            console.log("GlobalShortcut pressed - toggling overlay")
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
            isDebugLoggingEnabled: root.isDebugLoggingEnabled
            
            // Pass notification function for UI error handling
            property var notifyUser: root.notifyUser
            
            onSnippetSelected: function(snippet) {
                console.log("📋 Selected snippet:", snippet.title)
                root.debugLog("🚀 Launching detached script with text argument...")
                
                // Validate snippet data before processing
                if (!root.validateSnippetData(snippet)) {
                    console.error("❌ Invalid snippet data - cannot inject text")
                    root.notifyUser("Snippet Manager Error", "Invalid snippet data - text injection failed", "critical")
                    Qt.quit()
                    return
                }
                
                try {
                    // Use execDetached with command array (like DesktopAction.command)
                    const scriptPath = Qt.resolvedUrl("inject-text.sh").toString().replace("file://", "")
                    
                    // Validate script path exists
                    if (!scriptPath || scriptPath.length === 0) {
                        throw new Error("Script path could not be resolved")
                    }
                    
                    var command = [scriptPath, snippet.content]
                    root.debugLog("🔧 Executing command: " + JSON.stringify(command))
                    
                    Quickshell.execDetached(command)
                    root.debugLog("✅ Text injection command launched successfully")
                } catch (error) {
                    console.error("❌ Failed to execute text injection script:", error)
                    root.notifyUser("Snippet Manager Error", 
                                  "Failed to inject text: " + error.message, 
                                  "critical")
                }
                
                // Exit immediately (even on error - user should be notified via notification)
                Qt.quit()
            }
            
            onDismissed: {
                console.log("❌ Snippet manager dismissed")
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
