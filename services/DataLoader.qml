import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    
    property var snippets: []
    property bool loaded: false
    property string error: ""
    
    readonly property string dataPath: Quickshell.env("HOME") + "/.config/quickshell/snippet-manager/snippets.json"
    readonly property string fallbackPath: Qt.resolvedUrl("../data/snippets.json")
    
    Component.onCompleted: loadSnippets()
    
    function loadSnippets() {
        // For Phase 1, use hardcoded test data
        console.log("DataLoader: Using hardcoded test data for Phase 1")
        
        var testSnippets = [
            {
                "id": "greeting-hello",
                "title": "Hello greeting",
                "content": "Hello! How are you doing today?"
            },
            {
                "id": "email-signature",
                "title": "Email signature",
                "content": "Best regards,\nJohn Doe\nSoftware Developer\njohn.doe@email.com"
            },
            {
                "id": "code-function",
                "title": "JavaScript function template",
                "content": "function functionName() {\n    // TODO: Implement function logic\n    return;\n}"
            },
            {
                "id": "meeting-template",
                "title": "Meeting notes template", 
                "content": "## Meeting Notes - [Date]\n\n### Attendees\n- \n\n### Agenda\n- \n\n### Action Items\n- \n\n### Next Steps\n- "
            },
            {
                "id": "git-commit",
                "title": "Git commit message template",
                "content": "feat: add new feature\n\n- Implement core functionality\n- Add unit tests\n- Update documentation"
            }
        ]
        
        root.snippets = testSnippets
        root.loaded = true
        root.error = ""
        console.log("DataLoader: Successfully loaded", testSnippets.length, "test snippets")
    }
    
    function readFile(path, callback) {
        console.log("DataLoader: Attempting to read file:", path)
        
        // Create a direct Process component  
        var processComponent = Qt.createComponent("qrc:/Quickshell.Io/Process.qml")
        if (processComponent.status === Component.Ready) {
            var process = processComponent.createObject(root)
            process.command = ["cat", path]
            
            process.runningChanged.connect(function() {
                if (!process.running && process.hasExited) {
                    if (process.exitCode === 0) {
                        callback(true, process.stdout)
                    } else {
                        callback(false, process.stderr)
                    }
                    process.destroy()
                }
            })
            
            process.errorOccurred.connect(function() {
                callback(false, process.errorString)
                process.destroy()
            })
            
            process.start()
        } else {
            console.error("DataLoader: Could not create Process component:", processComponent.errorString())
            callback(false, "Could not create Process component")
        }
    }
    
    function parseAndSetSnippets(content, source) {
        try {
            var parsed = JSON.parse(content)
            if (Array.isArray(parsed)) {
                root.snippets = parsed
                root.loaded = true
                root.error = ""
                console.log("DataLoader: Successfully loaded", parsed.length, "snippets from", source)
            } else {
                root.error = "Invalid JSON format: expected array"
                console.error("DataLoader:", root.error)
            }
        } catch (e) {
            root.error = "JSON parse error: " + e.message
            console.error("DataLoader:", root.error)
            if (source === "main") {
                tryFallbackPath()
            }
        }
    }
    
    function getSnippetById(id) {
        for (var i = 0; i < snippets.length; i++) {
            if (snippets[i].id === id) {
                return snippets[i]
            }
        }
        return null
    }
    
    function getSnippetByIndex(index) {
        if (index >= 0 && index < snippets.length) {
            return snippets[index]
        }
        return null
    }
}