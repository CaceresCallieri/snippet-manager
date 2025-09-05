import QtQuick
import "../utils"

Item {
    id: emptyState
    
    Column {
        anchors.centerIn: parent
        spacing: Constants.itemSpacing * 2
        width: parent.width * 0.9
        
        // Main empty state message
        Text {
            width: parent.width
            text: "No Snippets Available"
            color: "#ffffff"
            font.pixelSize: Constants.headerFontSize
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }
        
        // Guidance message
        Text {
            width: parent.width
            text: "Add snippets to data/snippets.json to get started"
            color: "#cccccc"
            font.pixelSize: Constants.snippetFontSize
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
        
        // Additional help text
        Text {
            width: parent.width
            text: "File location: data/snippets.json"
            color: "#888888"
            font.pixelSize: Constants.instructionsFontSize - 1
            horizontalAlignment: Text.AlignHCenter
            font.italic: true
        }
    }
}