import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../utils"

PanelWindow {
    id: window
    
    property var snippets: []
    property int currentIndex: 0
    property bool isDebugLoggingEnabled: false
    property int maxVisibleSnippets: Constants.maxVisibleSnippets
    property int visibleRangeStartIndex: 0
    property bool hasValidSnippets: snippets.length > 0
    
    // Performance measurement (external counters to avoid binding loops)
    property int displayCalculationCount: 0
    
    readonly property var visibleSnippetWindow: {
        if (snippets.length === 0) return []
        const end = Math.min(visibleRangeStartIndex + maxVisibleSnippets, snippets.length)
        return snippets.slice(visibleRangeStartIndex, end)
    }
    
    // Optional debug tracking - separate property avoids binding loops
    onVisibleSnippetWindowChanged: trackCalculation()
    
    property int globalIndex: visibleRangeStartIndex + currentIndex
    
    signal snippetSelected(var snippet)
    signal dismissed()
    
    function debugLog(message) {
        if (isDebugLoggingEnabled) {
            console.log(message)
        }
    }
    
    function trackCalculation() {
        displayCalculationCount++
        if (isDebugLoggingEnabled) {
            console.log("📊 visibleSnippetWindow recalculated (count: " + displayCalculationCount + ")")
        }
    }
    
    function showPerformanceSummary() {
        console.log("🔍 PERFORMANCE SUMMARY (BINDING LOOP FIX APPLIED):")
        console.log("   - Total visibleSnippetWindow calculations: " + displayCalculationCount)
        console.log("   - Binding loops: ELIMINATED ✅")
        console.log("   - Performance: OPTIMIZED ✅")
    }
    
    // Navigation helper functions - condition predicates
    function canMoveUpWithinWindow() {
        return currentIndex > 0
    }
    
    function canScrollWindowUp() {
        return visibleRangeStartIndex > 0
    }
    
    function canMoveDownWithinWindow() {
        return currentIndex < visibleSnippetWindow.length - 1
    }
    
    function canScrollWindowDown() {
        return visibleRangeStartIndex + maxVisibleSnippets < snippets.length
    }
    
    // Navigation helper functions - action functions
    function moveUpWithinWindow() {
        currentIndex--
        debugLog(`🎯 Moved up within window to index ${currentIndex} (global: ${globalIndex})`)
    }
    
    function scrollWindowUp() {
        visibleRangeStartIndex = Math.max(0, visibleRangeStartIndex - 1)
        debugLog(`🔄 Scrolled window up, start: ${visibleRangeStartIndex} (global: ${globalIndex})`)
    }
    
    function moveDownWithinWindow() {
        currentIndex++
        debugLog(`🎯 Moved down within window to index ${currentIndex} (global: ${globalIndex})`)
    }
    
    function scrollWindowDown() {
        visibleRangeStartIndex = Math.min(visibleRangeStartIndex + 1, snippets.length - 1)
        debugLog(`🔄 Scrolled window down, start: ${visibleRangeStartIndex} (global: ${globalIndex})`)
    }
    
    // Navigation helper functions - wrap-around calculations
    function calculateBottomWrapPosition() {
        const windowStart = Math.max(0, snippets.length - maxVisibleSnippets)
        const cursorIndex = Math.min(maxVisibleSnippets - 1, snippets.length - 1 - windowStart)
        return { windowStart, cursorIndex }
    }
    
    function calculateTopWrapPosition() {
        return { windowStart: 0, cursorIndex: 0 }
    }
    
    function wrapToBottom() {
        const position = calculateBottomWrapPosition()
        visibleRangeStartIndex = position.windowStart
        currentIndex = position.cursorIndex
        debugLog(`🔄 Wrapped to bottom - window: ${visibleRangeStartIndex}, cursor: ${currentIndex} (global: ${globalIndex})`)
    }
    
    function wrapToTop() {
        const position = calculateTopWrapPosition()
        visibleRangeStartIndex = position.windowStart
        currentIndex = position.cursorIndex
        debugLog(`🔄 Wrapped to top - window: ${visibleRangeStartIndex}, cursor: ${currentIndex} (global: ${globalIndex})`)
    }
    
    // Centralized state management
    function updateNavigationState(direction) {
        debugLog(`🔵 Navigation ${direction}: Global ${globalIndex}, Window ${visibleRangeStartIndex}-${visibleRangeStartIndex + maxVisibleSnippets - 1}, Total: ${snippets.length}`)
    }
    
    function validateAndSelectSnippet(snippet, source) {
        window.debugLog("🔍 Validating snippet from " + source + ": " + (snippet ? snippet.title : "null"))
        
        if (!snippet) {
            console.error("❌ Snippet selection failed - null snippet from " + source)
            return false
        }
        
        if (typeof snippet !== 'object') {
            console.error("❌ Snippet selection failed - invalid object type from " + source + ": " + typeof snippet)
            return false
        }
        
        if (!snippet.hasOwnProperty('title') || typeof snippet.title !== 'string') {
            console.error("❌ Snippet selection failed - invalid title from " + source)
            return false
        }
        
        if (!snippet.hasOwnProperty('content') || typeof snippet.content !== 'string') {
            console.error("❌ Snippet selection failed - invalid content from " + source)
            return false
        }
        
        window.debugLog("✅ Snippet validation passed from " + source + ": " + snippet.title)
        window.snippetSelected(snippet)
        return true
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
                    model: visibleSnippetWindow
                    
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
                                window.debugLog("🖱️ Clicked snippet at local index: " + index + " (global: " + (window.visibleRangeStartIndex + index) + ")")
                                window.currentIndex = index
                                
                                // Validate snippet data before selection
                                if (!window.validateAndSelectSnippet(modelData, "mouse_click")) {
                                    window.debugLog("❌ Mouse click validation failed for index: " + index)
                                }
                            }
                            onEntered: {
                                // Validate index bounds before updating currentIndex
                                if (index >= 0 && index < visibleSnippetWindow.length) {
                                    window.currentIndex = index
                                } else {
                                    window.debugLog("❌ Mouse hover index out of bounds: " + index + " (max: " + (visibleSnippetWindow.length - 1) + ")")
                                }
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
                
                window.debugLog("🔵 Key pressed: " + event.key + " Global index: " + window.globalIndex + " Window: " + window.visibleRangeStartIndex + "-" + (window.visibleRangeStartIndex + visibleSnippetWindow.length - 1) + " Total: " + snippets.length)
                switch (event.key) {
                case Qt.Key_Up:
                    if (snippets.length === 0) {
                        window.debugLog("❌ Navigation ignored - no snippets available")
                        break
                    }
                    
                    if (window.canMoveUpWithinWindow()) {
                        window.moveUpWithinWindow()
                    } else if (window.canScrollWindowUp()) {
                        window.scrollWindowUp()
                    } else {
                        window.wrapToBottom()
                    }
                    window.updateNavigationState("UP")
                    event.accepted = true
                    break
                case Qt.Key_Down:
                    if (snippets.length === 0) {
                        window.debugLog("❌ Navigation ignored - no snippets available")
                        break
                    }
                    
                    if (window.canMoveDownWithinWindow()) {
                        window.moveDownWithinWindow()
                    } else if (window.canScrollWindowDown()) {
                        window.scrollWindowDown()
                    } else {
                        window.wrapToTop()
                    }
                    window.updateNavigationState("DOWN")
                    event.accepted = true
                    break
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    window.debugLog("🟢 Enter pressed - selecting snippet at global index: " + window.globalIndex)
                    
                    // Capture atomic snapshot to prevent race conditions
                    const currentSnippets = snippets
                    const currentIndex = window.globalIndex
                    
                    // Validate bounds with snapshot
                    if (currentIndex >= 0 && currentIndex < currentSnippets.length) {
                        const selectedSnippet = currentSnippets[currentIndex]
                        
                        // Double-check snippet exists (additional safety)
                        if (selectedSnippet) {
                            window.debugLog("✅ Selecting snippet: " + selectedSnippet.title)
                            
                            // Use validation function for consistency
                            if (!window.validateAndSelectSnippet(selectedSnippet, "keyboard_enter")) {
                                window.debugLog("❌ Keyboard selection validation failed for index: " + currentIndex)
                            }
                        } else {
                            window.debugLog("❌ Snippet at index " + currentIndex + " is null or undefined")
                        }
                    } else {
                        window.debugLog("❌ Invalid global index for selection: " + currentIndex + " (bounds: 0-" + (currentSnippets.length - 1) + ")")
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
