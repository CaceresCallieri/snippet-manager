import QtQuick
import "../utils"

Item {
    id: emptyState
    
    // Properties to customize empty state context
    property string searchTerm: ""
    property bool isSearchActive: false
    property int totalSnippets: 0
    
    Column {
        anchors.centerIn: parent
        spacing: Constants.itemSpacing * 2
        width: parent.width * Constants.layout.emptyStateWidthFraction
        
        // Main empty state message
        Text {
            width: parent.width
            text: {
                if (isSearchActive && totalSnippets > 0) {
                    return `No matches for "${searchTerm}"`
                } else if (totalSnippets === 0) {
                    return "No Snippets Available"
                } else {
                    return "No Results"
                }
            }
            color: "#ffffff"
            font.pixelSize: Constants.headerFontSize
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }
        
        // Guidance message
        Text {
            width: parent.width
            text: {
                if (isSearchActive && totalSnippets > 0) {
                    return "Try different search terms or clear the search"
                } else if (totalSnippets === 0) {
                    return "Add snippets to data/snippets.json to get started"
                } else {
                    return "No snippets found"
                }
            }
            color: "#cccccc"
            font.pixelSize: Constants.snippetFontSize
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
        
        // Additional help text
        Text {
            width: parent.width
            text: {
                if (isSearchActive && totalSnippets > 0) {
                    return `${totalSnippets} snippets available`
                } else if (totalSnippets === 0) {
                    return "File location: data/snippets.json"
                } else {
                    return ""
                }
            }
            visible: text.length > 0
            color: Constants.search.noResultsColor
            font.pixelSize: Constants.instructionsFontSize - 1
            horizontalAlignment: Text.AlignHCenter
            font.italic: true
        }
    }
}