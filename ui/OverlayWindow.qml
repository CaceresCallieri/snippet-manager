import QtQuick
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id: window
    
    property var snippets: []
    property int currentIndex: 0
    property bool debugMode: false
    
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
    
    implicitWidth: 500
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
            text: "Snippet Manager (" + snippets.length + " snippets)"
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
                model: snippets
                
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
                            console.log("Clicked snippet", index)
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
                window.debugLog("🔵 Key pressed: " + event.key + " Current index: " + window.currentIndex + " Snippets count: " + snippets.length)
                switch (event.key) {
                case Qt.Key_Escape:
                    window.debugLog("🔴 Escape pressed - dismissing overlay")
                    window.dismissed()
                    event.accepted = true
                    break
                case Qt.Key_Up:
                    window.debugLog("🔼 Up arrow pressed - current index: " + window.currentIndex)
                    if (window.currentIndex > 0) {
                        window.currentIndex--
                        window.debugLog("✅ Moved up to index: " + window.currentIndex)
                    } else {
                        window.debugLog("⚠️ Already at top, cannot move up")
                    }
                    event.accepted = true
                    break
                case Qt.Key_Down:
                    window.debugLog("🔽 Down arrow pressed - current index: " + window.currentIndex)
                    if (window.currentIndex < snippets.length - 1) {
                        window.currentIndex++
                        window.debugLog("✅ Moved down to index: " + window.currentIndex)
                    } else {
                        window.debugLog("⚠️ Already at bottom, cannot move down")
                    }
                    event.accepted = true
                    break
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    window.debugLog("🟢 Enter pressed - selecting snippet at index: " + window.currentIndex)
                    if (window.currentIndex >= 0 && window.currentIndex < snippets.length) {
                        window.debugLog("✅ Selecting snippet: " + snippets[window.currentIndex].title)
                        window.snippetSelected(snippets[window.currentIndex])
                    } else {
                        window.debugLog("❌ Invalid index for selection")
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
