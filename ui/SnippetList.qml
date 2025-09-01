import QtQuick

ListView {
    id: listView
    
    property var snippets: []
    
    signal snippetSelected(var snippet)
    
    model: snippets
    currentIndex: 0
    highlightFollowsCurrentItem: true
    keyNavigationEnabled: false
    focus: true
    
    Rectangle {
        anchors.fill: parent
        color: "#2a2a2a"
        border.color: "#404040"
        border.width: 1
    }
    
    delegate: Rectangle {
        id: delegateItem
        
        width: listView.width
        height: 60
        
        color: ListView.isCurrentItem ? "#404040" : "transparent"
        
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: "#333333"
        }
        
        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 4
            
            Text {
                text: modelData.title || ""
                color: ListView.isCurrentItem ? "#ffffff" : "#e0e0e0"
                font.pixelSize: 14
                font.weight: Font.Medium
                elide: Text.ElideRight
                width: parent.width
            }
            
            Text {
                text: (modelData.content || "").substring(0, 100) + (modelData.content && modelData.content.length > 100 ? "..." : "")
                color: ListView.isCurrentItem ? "#cccccc" : "#999999"
                font.pixelSize: 12
                elide: Text.ElideRight
                width: parent.width
                wrapMode: Text.NoWrap
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                listView.currentIndex = index
                listView.snippetSelected(modelData)
            }
        }
    }
    
    function moveUp() {
        if (listView.currentIndex > 0) {
            listView.currentIndex--
        }
    }
    
    function moveDown() {
        if (listView.currentIndex < snippets.length - 1) {
            listView.currentIndex++
        }
    }
    
    function selectCurrent() {
        if (listView.currentIndex >= 0 && listView.currentIndex < snippets.length) {
            snippetSelected(snippets[listView.currentIndex])
        }
    }
}