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
    
    function loadSnippets() {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        const parsed = JSON.parse(xhr.responseText)
                        if (Array.isArray(parsed)) {
                            root.snippets = parsed
                            console.log("✅ Loaded " + root.snippets.length + " snippets from JSON file")
                            root.debugLog("🔍 Snippets loaded: " + JSON.stringify(root.snippets, null, 2))
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
        xhr.open("GET", "data/snippets.json")
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
                var command = ["/home/jc/Dev/snippet-manager/inject-text.sh", snippet.content]
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
