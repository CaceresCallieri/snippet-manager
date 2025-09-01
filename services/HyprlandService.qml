import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: root
    
    signal globalShortcutTriggered()
    
    property point cursorPosition: Qt.point(0, 0)
    property bool ready: true
    
    GlobalShortcut {
        name: "show-snippet-manager"
        description: "Show snippet manager overlay"
        
        onPressed: {
            updateCursorPosition()
            root.globalShortcutTriggered()
        }
    }
    
    function updateCursorPosition() {
        var process = Qt.createQmlObject('
            import Quickshell.Io;
            Process {
                command: ["hyprctl", "cursorpos"]
                
                Component.onCompleted: start()
                
                onRunningChanged: {
                    if (!running && hasExited && exitCode === 0) {
                        var output = stdout.trim()
                        var coords = output.split(",")
                        if (coords.length >= 2) {
                            var x = parseInt(coords[0].trim())
                            var y = parseInt(coords[1].trim())
                            if (!isNaN(x) && !isNaN(y)) {
                                root.cursorPosition = Qt.point(x, y)
                                console.log("HyprlandService: Updated cursor position:", x, y)
                            }
                        }
                        destroy()
                    } else if (!running && hasExited) {
                        console.warn("HyprlandService: hyprctl failed with code:", exitCode)
                        destroy()
                    }
                }
                
                onErrorOccurred: {
                    console.warn("HyprlandService: Failed to get cursor position:", errorString)
                    destroy()
                }
            }
        ', root)
    }
    
    function getCursorPosition() {
        updateCursorPosition()
        return root.cursorPosition
    }
}