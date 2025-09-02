import QtQuick
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id: window
    
    property var snippets: []
    property int currentIndex: 0
    property bool debugMode: false
    property int maxDisplayed: 5
    property int windowStart: 0
    property var displayedSnippets: snippets.slice(windowStart, windowStart + Math.min(maxDisplayed, snippets.length - windowStart))
    property int globalIndex: windowStart + currentIndex
    
    signal snippetSelected(var snippet)
    signal dismissed()
    
    function debugLog(message) {
        if (debugMode) {
            console.log(message)
        }
    }
    
    anchors.top: true
    margins.top: screen.height / 6
    exclusiveZone: 0
    
    implicitWidth: 350
    implicitHeight: 320
    color: "transparent"
    
    HyprlandFocusGrab {
        id: focusGrab
        windows: [window]
        active: true
        
        
        onCleared: {
            window.debugLog("🔴 Focus grab cleared - dismissing overlay")
            window.dismissed()
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"
        border.color: "#666666"
        border.width: 1
        radius: 8
        
        Text {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            height: 40
            text: "Snippet Manager (" + (globalIndex + 1) + " of " + snippets.length + " snippets)"
            color: "#ffffff"
            font.pixelSize: 18
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        Column {
            id: snippetColumn
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: instructions.top
            anchors.margins: 15
            anchors.topMargin: 10
            spacing: 5
            
            Repeater {
                model: displayedSnippets
                
                Rectangle {
                    width: snippetColumn.width
                    height: 35
                    color: index === window.currentIndex ? "#444444" : "#2a2a2a"
                    border.color: index === window.currentIndex ? "#ffffff" : "#555555"
                    border.width: 1
                    radius: 6
                    
                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: 15
                        text: modelData.title || "Untitled"
                        color: index === window.currentIndex ? "#ffffff" : "#cccccc"
                        font.pixelSize: 14
                        font.bold: false
                        elide: Text.ElideRight
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            window.debugLog("🖱️ Clicked snippet at local index: " + index + " (global: " + (window.windowStart + index) + ")")
                            window.currentIndex = index
                            window.snippetSelected(modelData)
                        }
                        onEntered: {
                            window.currentIndex = index
                        }
                    }
                }
            }
        }
        
        Text {
            id: instructions
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 15
            height: 25
            text: "↑↓ Navigate • Enter Select • Esc Cancel"
            color: "#aaaaaa"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        Item {
            id: keyHandler
            anchors.fill: parent
            focus: true
            
            onFocusChanged: window.debugLog("🎯 keyHandler focus changed: " + focus)
            onActiveFocusChanged: window.debugLog("🎯 keyHandler activeFocus changed: " + activeFocus)
            
            Keys.onPressed: function(event) {
                window.debugLog("🔵 Key pressed: " + event.key + " Global index: " + window.globalIndex + " Window: " + window.windowStart + "-" + (window.windowStart + displayedSnippets.length - 1) + " Total: " + snippets.length)
                switch (event.key) {
                case Qt.Key_Escape:
                    window.debugLog("🔴 Escape pressed - dismissing overlay")
                    window.dismissed()
                    event.accepted = true
                    break
                case Qt.Key_Up:
                    window.debugLog("🔼 Up arrow pressed - currentIndex: " + window.currentIndex + " windowStart: " + window.windowStart)
                    if (window.currentIndex > 0) {
                        // Move cursor up within window
                        window.currentIndex--
                        window.debugLog("✅ Moved up to local index: " + window.currentIndex + " (global: " + window.globalIndex + ")")
                    } else if (window.windowStart > 0) {
                        // Scroll window up by 1, keep cursor at top
                        window.windowStart--
                        window.debugLog("🔄 Scrolled window up - new window: " + window.windowStart + "-" + (window.windowStart + displayedSnippets.length - 1) + " (global: " + window.globalIndex + ")")
                    } else {
                        // Wrap around to last snippet
                        window.windowStart = Math.max(0, snippets.length - window.maxDisplayed)
                        window.currentIndex = Math.min(window.maxDisplayed - 1, snippets.length - 1 - window.windowStart)
                        window.debugLog("🔄 Wrapped around to bottom - new window: " + window.windowStart + "-" + (window.windowStart + displayedSnippets.length - 1) + " (global: " + window.globalIndex + ")")
                    }
                    event.accepted = true
                    break
                case Qt.Key_Down:
                    window.debugLog("🔽 Down arrow pressed - currentIndex: " + window.currentIndex + " windowStart: " + window.windowStart)
                    if (window.currentIndex < displayedSnippets.length - 1) {
                        // Move cursor down within window
                        window.currentIndex++
                        window.debugLog("✅ Moved down to local index: " + window.currentIndex + " (global: " + window.globalIndex + ")")
                    } else if (window.windowStart + window.maxDisplayed < snippets.length) {
                        // Scroll window down by 1, keep cursor at bottom
                        window.windowStart++
                        window.debugLog("🔄 Scrolled window down - new window: " + window.windowStart + "-" + (window.windowStart + displayedSnippets.length - 1) + " (global: " + window.globalIndex + ")")
                    } else {
                        // Wrap around to first snippet
                        window.windowStart = 0
                        window.currentIndex = 0
                        window.debugLog("🔄 Wrapped around to top - new window: " + window.windowStart + "-" + (window.windowStart + displayedSnippets.length - 1) + " (global: " + window.globalIndex + ")")
                    }
                    event.accepted = true
                    break
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    window.debugLog("🟢 Enter pressed - selecting snippet at global index: " + window.globalIndex)
                    if (window.globalIndex >= 0 && window.globalIndex < snippets.length) {
                        window.debugLog("✅ Selecting snippet: " + snippets[window.globalIndex].title)
                        window.snippetSelected(snippets[window.globalIndex])
                    } else {
                        window.debugLog("❌ Invalid global index for selection")
                    }
                    event.accepted = true
                    break
                default:
                    window.debugLog("🔸 Unhandled key: " + event.key)
                    break
                }
            }
        }
    }
    
    Component.onCompleted: {
        console.log("OverlayWindow: Created with", snippets.length, "snippets")
        window.debugLog("🎯 Setting focus to keyHandler")
        // Try multiple approaches to gain active focus
        keyHandler.focus = true
        keyHandler.forceActiveFocus()
        Qt.callLater(function() {
            keyHandler.forceActiveFocus()
            window.debugLog("🎯 After callLater - keyHandler focus: " + keyHandler.focus)
            window.debugLog("🎯 After callLater - keyHandler activeFocus: " + keyHandler.activeFocus)
        })
        window.debugLog("🎯 keyHandler focus: " + keyHandler.focus)
        window.debugLog("🎯 keyHandler activeFocus: " + keyHandler.activeFocus)
        window.debugLog("🎯 window focus: " + window.focus)
        window.debugLog("🎯 window activeFocus: " + window.activeFocus)
    }
}
