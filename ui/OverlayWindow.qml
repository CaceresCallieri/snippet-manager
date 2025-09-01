import QtQuick
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id: window
    
    property var snippets: []
    property int currentIndex: 0
    
    signal snippetSelected(var snippet)
    signal dismissed()
    
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
            console.log("🔴 Focus grab cleared - dismissing overlay")
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
            
            onFocusChanged: console.log("🎯 keyHandler focus changed:", focus)
            onActiveFocusChanged: console.log("🎯 keyHandler activeFocus changed:", activeFocus)
            
            Keys.onPressed: function(event) {
                console.log("🔵 Key pressed:", event.key, "Current index:", window.currentIndex, "Snippets count:", snippets.length)
                switch (event.key) {
                case Qt.Key_Escape:
                    console.log("🔴 Escape pressed - dismissing overlay")
                    window.dismissed()
                    event.accepted = true
                    break
                case Qt.Key_Up:
                    console.log("🔼 Up arrow pressed - current index:", window.currentIndex)
                    if (window.currentIndex > 0) {
                        window.currentIndex--
                        console.log("✅ Moved up to index:", window.currentIndex)
                    } else {
                        console.log("⚠️ Already at top, cannot move up")
                    }
                    event.accepted = true
                    break
                case Qt.Key_Down:
                    console.log("🔽 Down arrow pressed - current index:", window.currentIndex)
                    if (window.currentIndex < snippets.length - 1) {
                        window.currentIndex++
                        console.log("✅ Moved down to index:", window.currentIndex)
                    } else {
                        console.log("⚠️ Already at bottom, cannot move down")
                    }
                    event.accepted = true
                    break
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    console.log("🟢 Enter pressed - selecting snippet at index:", window.currentIndex)
                    if (window.currentIndex >= 0 && window.currentIndex < snippets.length) {
                        console.log("✅ Selecting snippet:", snippets[window.currentIndex].title)
                        window.snippetSelected(snippets[window.currentIndex])
                    } else {
                        console.log("❌ Invalid index for selection")
                    }
                    event.accepted = true
                    break
                default:
                    console.log("🔸 Unhandled key:", event.key)
                    break
                }
            }
        }
    }
    
    Component.onCompleted: {
        console.log("OverlayWindow: Created with", snippets.length, "snippets")
        console.log("🎯 Setting focus to keyHandler")
        // Try multiple approaches to gain active focus
        keyHandler.focus = true
        keyHandler.forceActiveFocus()
        Qt.callLater(function() {
            keyHandler.forceActiveFocus()
            console.log("🎯 After callLater - keyHandler focus:", keyHandler.focus)
            console.log("🎯 After callLater - keyHandler activeFocus:", keyHandler.activeFocus)
        })
        console.log("🎯 keyHandler focus:", keyHandler.focus)
        console.log("🎯 keyHandler activeFocus:", keyHandler.activeFocus)
        console.log("🎯 window focus:", window.focus)
        console.log("🎯 window activeFocus:", window.activeFocus)
    }
}
