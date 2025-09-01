import QtQuick
import Quickshell
import Quickshell.Hyprland
import "ui" as UI

ShellRoot {
    id: root
    
    property bool shouldShowOverlay: true
    property var snippets: [
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
    
    GlobalShortcut {
        name: "show-snippet-manager"
        description: "Show snippet manager overlay"
        
        onPressed: {
            console.log("GlobalShortcut pressed - toggling overlay")
            root.shouldShowOverlay = !root.shouldShowOverlay
        }
    }
    
    function injectText(text) {
        console.log("Injecting text:", text.substring(0, 50) + (text.length > 50 ? "..." : ""))
        
        // Simple Process execution
        var process = Qt.createQmlObject('
            import QtQuick;
            import Quickshell.Io;
            Process {
                property string textToInject
                command: ["wtype", textToInject]
                
                Component.onCompleted: start()
                
                onRunningChanged: {
                    if (!running && hasExited) {
                        if (exitCode === 0) {
                            console.log("✅ Text injection successful")
                        } else {
                            console.error("❌ Text injection failed with code:", exitCode)
                        }
                        destroy()
                    }
                }
            }
        ', root)
        
        process.textToInject = text
    }
    
    // Use LazyLoader for memory efficiency when overlay isn't shown
    LazyLoader {
        active: root.shouldShowOverlay
        
        UI.OverlayWindow {
            snippets: root.snippets
            
            onSnippetSelected: function(snippet) {
                console.log("📋 Selected snippet:", snippet.title)
                root.injectText(snippet.content)
                // Exit after injection
                Qt.callLater(function() { Qt.quit() })
            }
            
            onDismissed: {
                console.log("❌ Snippet manager dismissed")
                Qt.quit()
            }
        }
    }
}