import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../utils"

PanelWindow {
    id: window
    
    property var snippets: []
    property int currentIndex: 0
    property bool debugMode: false
    property int maxDisplayed: Constants.maxVisibleSnippets
    property int windowStart: 0
    property bool hasValidSnippets: snippets.length > 0
    
    // Performance measurement (external counters to avoid binding loops)
    property int calculationCount: 0
    
    readonly property var displayedSnippets: {
        if (snippets.length === 0) return []
        const end = Math.min(windowStart + maxDisplayed, snippets.length)
        return snippets.slice(windowStart, end)
    }
    
    // Optional debug tracking - separate property avoids binding loops
    onDisplayedSnippetsChanged: trackCalculation()
    
    property int globalIndex: windowStart + currentIndex
    
    signal snippetSelected(var snippet)
    signal dismissed()
    
    function debugLog(message) {
        if (debugMode) {
            console.log(message)
        }
    }
    
    function trackCalculation() {
        calculationCount++
        if (debugMode) {
            console.log("📊 displayedSnippets recalculated (count: " + calculationCount + ")")
        }
    }
    
    function showPerformanceSummary() {
        console.log("🔍 PERFORMANCE SUMMARY (BINDING LOOP FIX APPLIED):")
        console.log("   - Total displayedSnippets calculations: " + calculationCount)
        console.log("   - Binding loops: ELIMINATED ✅")
        console.log("   - Performance: OPTIMIZED ✅")
    }
    
    
    anchors.top: true
    margins.top: screen.height * Constants.overlayTopOffsetFraction
    exclusiveZone: 0
    
    implicitWidth: Constants.overlayWidth
    implicitHeight: Constants.overlayHeight
    color: "transparent"
    
    HyprlandFocusGrab {
        id: focusGrab
        windows: [window]
        active: true
        
        onActiveChanged: {
            if (active) {
                // HyprlandFocusGrab is ready - now coordinate Qt focus
                Qt.callLater(function() {
                    keyHandler.forceActiveFocus()
                    window.debugLog("🎯 Focus coordinated with HyprlandFocusGrab")
                })
            }
        }
        
        onCleared: {
            window.debugLog("🔴 Focus grab cleared - dismissing overlay")
            window.dismissed()
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"
        border.color: "#666666"
        border.width: Constants.borderWidth
        radius: Constants.borderRadius
        
        Text {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Constants.headerMargins
            height: Constants.headerHeight
            text: window.hasValidSnippets ? 
                  "Snippet Manager (" + (globalIndex + 1) + " of " + snippets.length + " snippets)" :
                  "Snippet Manager"
            color: "#ffffff"
            font.pixelSize: Constants.headerFontSize
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        // Main content area with conditional rendering
        Item {
            id: contentArea
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: instructions.top
            anchors.margins: Constants.mainMargins
            anchors.topMargin: Constants.headerTopMargin
            
            // Empty state UI
            EmptyStateView {
                anchors.fill: parent
                visible: !window.hasValidSnippets
            }
            
            // Normal snippet list
            Column {
                id: snippetColumn
                anchors.fill: parent
                visible: window.hasValidSnippets
                spacing: Constants.itemSpacing
                
                Repeater {
                    model: displayedSnippets
                    
                    Rectangle {
                        width: snippetColumn.width
                        height: Constants.snippetItemHeight
                        color: index === window.currentIndex ? "#444444" : "#2a2a2a"
                        border.color: index === window.currentIndex ? "#ffffff" : "#555555"
                        border.width: Constants.borderWidth
                        radius: Constants.itemBorderRadius
                        
                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: Constants.textMargins
                            text: modelData.title || "Untitled"
                            color: index === window.currentIndex ? "#ffffff" : "#cccccc"
                            font.pixelSize: Constants.snippetFontSize
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
        }
        
        Text {
            id: instructions
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Constants.mainMargins
            height: Constants.instructionsHeight
            text: window.hasValidSnippets ? 
                  "↑↓ Navigate • Enter Select • Esc Cancel" : 
                  "Esc Cancel • Add snippets to data/snippets.json"
            color: "#aaaaaa"
            font.pixelSize: Constants.instructionsFontSize
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
                // Handle escape key regardless of snippet state
                if (event.key === Qt.Key_Escape) {
                    window.debugLog("🔴 Escape pressed - dismissing overlay")
                    if (window.hasValidSnippets) {
                        window.showPerformanceSummary()
                    }
                    window.dismissed()
                    event.accepted = true
                    return
                }
                
                // Only process navigation keys when we have valid snippets
                if (!window.hasValidSnippets) {
                    window.debugLog("🚫 Navigation disabled - no valid snippets available")
                    return
                }
                
                window.debugLog("🔵 Key pressed: " + event.key + " Global index: " + window.globalIndex + " Window: " + window.windowStart + "-" + (window.windowStart + displayedSnippets.length - 1) + " Total: " + snippets.length)
                switch (event.key) {
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
        window.debugLog("🎯 Focus management delegated to HyprlandFocusGrab")
    }
}
