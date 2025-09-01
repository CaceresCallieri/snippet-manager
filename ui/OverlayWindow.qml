import QtQuick
import Quickshell

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
    implicitHeight: 400
    color: "transparent"
    
    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"
        border.color: "#ffaa00"
        border.width: 3
        radius: 12
        
        Text {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            height: 40
            text: "📝 Snippet Manager (" + snippets.length + " snippets)"
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
                    height: 70
                    color: index === window.currentIndex ? "#0066cc" : "#3a3a3a"
                    border.color: index === window.currentIndex ? "#66aaff" : "#666666"
                    border.width: 2
                    radius: 8
                    
                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: 15
                        spacing: 10
                        
                        Text {
                            text: (index + 1)
                            color: index === window.currentIndex ? "#ffcc00" : "#aaaaaa"
                            font.pixelSize: 20
                            font.bold: true
                            width: 30
                        }
                        
                        Column {
                            width: parent.width - 50
                            spacing: 5
                            
                            Text {
                                text: modelData.title || "Untitled"
                                color: index === window.currentIndex ? "#ffffff" : "#dddddd"
                                font.pixelSize: 14
                                font.bold: true
                                width: parent.width
                                elide: Text.ElideRight
                            }
                            
                            Text {
                                text: (modelData.content || "").substring(0, 60) + "..."
                                color: index === window.currentIndex ? "#cccccc" : "#999999"
                                font.pixelSize: 11
                                width: parent.width
                                elide: Text.ElideRight
                            }
                        }
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
            
            Keys.onPressed: function(event) {
                console.log("Key pressed:", event.key)
                switch (event.key) {
                case Qt.Key_Escape:
                    window.dismissed()
                    event.accepted = true
                    break
                case Qt.Key_Up:
                    if (window.currentIndex > 0) {
                        window.currentIndex--
                    }
                    event.accepted = true
                    break
                case Qt.Key_Down:
                    if (window.currentIndex < snippets.length - 1) {
                        window.currentIndex++
                    }
                    event.accepted = true
                    break
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    if (window.currentIndex >= 0 && window.currentIndex < snippets.length) {
                        console.log("Enter pressed, selecting snippet", window.currentIndex)
                        window.snippetSelected(snippets[window.currentIndex])
                    }
                    event.accepted = true
                    break
                }
            }
        }
    }
    
    Component.onCompleted: {
        console.log("OverlayWindow: Created with", snippets.length, "snippets")
        keyHandler.forceActiveFocus()
    }
}