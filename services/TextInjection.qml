import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    
    property bool isInjecting: false
    
    signal injectionStarted()
    signal injectionCompleted()
    signal injectionFailed(string error)
    
    function injectText(text) {
        if (isInjecting) {
            console.warn("TextInjection: Already injecting, skipping")
            return
        }
        
        if (!text || text.length === 0) {
            injectionFailed("Empty text provided")
            return
        }
        
        isInjecting = true
        injectionStarted()
        
        console.log("TextInjection: Injecting text:", text.substring(0, 50) + (text.length > 50 ? "..." : ""))
        
        var process = Qt.createQmlObject('
            import Quickshell.Io;
            Process {
                property string textToInject
                command: ["wtype", textToInject]
                
                Component.onCompleted: start()
                
                onRunningChanged: {
                    if (!running && hasExited) {
                        if (exitCode === 0) {
                            console.log("TextInjection: Successfully injected text")
                            root.isInjecting = false
                            root.injectionCompleted()
                        } else {
                            var errorMsg = "wtype failed with exit code " + exitCode
                            if (stderr && stderr.length > 0) {
                                errorMsg += ": " + stderr
                            }
                            console.error("TextInjection:", errorMsg)
                            root.isInjecting = false
                            root.injectionFailed(errorMsg)
                        }
                        destroy()
                    }
                }
                
                onErrorOccurred: {
                    var errorMsg = "Process error: " + errorString
                    console.error("TextInjection:", errorMsg)
                    root.isInjecting = false
                    root.injectionFailed(errorMsg)
                    destroy()
                }
            }
        ', root)
        
        process.textToInject = text
    }
    
    function injectSnippet(snippet) {
        if (!snippet || !snippet.content) {
            injectionFailed("Invalid snippet provided")
            return
        }
        
        injectText(snippet.content)
    }
}