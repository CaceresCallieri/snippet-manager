import QtQuick
import Quickshell
import Quickshell.Hyprland
import "ui" as UI

ShellRoot {
    id: root
    
    property bool shouldShowOverlay: true
    // Debug mode toggle - change this to true/false as needed
    property bool debugMode: true
    property var snippets: []
    
    function debugLog(message) {
        if (debugMode) {
            console.log(message)
        }
    }
    
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
                            root.snippets = validSnippets
                            console.log(`✅ Validated ${validSnippets.length} of ${parsed.length} snippets from JSON file`)
                            if (validSnippets.length < parsed.length) {
                                console.warn(`⚠️  ${parsed.length - validSnippets.length} invalid snippets were filtered out`)
                            }
                            root.debugLog("🔍 Valid snippets loaded: " + JSON.stringify(root.snippets, null, 2))
                        } else {
                            console.error("❌ Invalid JSON: expected array, got " + typeof parsed)
                            root.snippets = []
                        }
                    } catch (e) {
                        console.error("❌ Failed to parse snippets JSON: " + e.message)
                        root.snippets = []
                    }
                } else {
                    console.error("❌ Failed to load snippets file. Status: " + xhr.status)
                    root.snippets = []
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
            root.shouldShowOverlay = !root.shouldShowOverlay
        }
    }
    
    // Detached script approach - no complex timers needed!
    
    // All injection logic moved to detached script - much simpler!
    
    // Window capture no longer needed for wtype approach
    
    // Use LazyLoader for memory efficiency when overlay isn't shown
    LazyLoader {
        active: root.shouldShowOverlay
        
        UI.OverlayWindow {
            snippets: root.snippets
            debugMode: root.debugMode
            
            onSnippetSelected: function(snippet) {
                console.log("📋 Selected snippet:", snippet.title)
                root.debugLog("🚀 Launching detached script with text argument...")
                
                // Use execDetached with command array (like DesktopAction.command)
                const scriptPath = Qt.resolvedUrl("inject-text.sh").toString().replace("file://", "")
                var command = [scriptPath, snippet.content]
                Quickshell.execDetached(command)
                
                // Exit immediately
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
