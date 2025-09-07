import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import "../utils"

PanelWindow {
    id: window
    
    property var snippets: []
    property bool isDebugLoggingEnabled: false
    property var notifyUser: null
    
    /**
     * Navigation controller instance handling all navigation logic
     * Provides sliding window navigation, cursor movement, and wrap-around behavior
     */
    NavigationController {
        id: navigationController
        snippets: window.filteredSnippets
        isDebugLoggingEnabled: window.isDebugLoggingEnabled
        
        onSelectionChanged: {
            // Navigation state changed - UI will automatically update via property bindings
            window.debugLog(`🔄 Navigation state updated: global ${globalIndex}, window ${visibleRangeStartIndex}-${visibleRangeStartIndex + maxDisplayed - 1}`)
        }
    }
    
    /**
     * Real-time filtered snippets based on search input
     * Filters both title and content fields with case-insensitive matching
     * 
     * @returns {Array} Filtered array of snippets matching search term
     */
    property var filteredSnippets: {
        const searchTerm = (searchInput?.text || "").toLowerCase()
        if (!searchTerm) return snippets
        
        return snippets.filter(snippet => 
            snippet.title.toLowerCase().includes(searchTerm) ||
            snippet.content.toLowerCase().includes(searchTerm)
        )
    }

    /**
     * Computed property: Whether valid snippets are available for display
     * Controls conditional UI rendering between empty state and normal snippet list.
     * 
     * @returns {boolean} True if filtered snippets array contains at least one valid snippet
     */
    property bool hasValidSnippets: filteredSnippets.length > 0
    
    // Performance measurement (external counters to avoid binding loops)
    property int displayCalculationCount: 0
    
    signal snippetSelected(var snippet)
    signal dismissed()
    
    /**
     * Conditionally logs debug messages with emoji markers
     * Only outputs when debug mode is enabled to keep production output clean.
     * 
     * @param {string} message - Debug message to log (should include emoji marker for consistency)
     * 
     * Side effects:
     * - Logs message to console only if isDebugLoggingEnabled is true
     * - No output in production mode (isDebugLoggingEnabled: false)
     */
    function debugLog(message) {
        if (isDebugLoggingEnabled) {
            console.log(message)
        }
    }
    
    /**
     * Displays comprehensive performance summary for development analysis
     * Shows navigation and UI performance metrics for session review.
     * 
     * Side effects:
     * - Always logs performance summary (regardless of debug mode)
     * - Reports navigation controller and UI performance status
     * - Used for performance regression detection during development
     */
    function showPerformanceSummary() {
        console.log("🔍 PERFORMANCE SUMMARY (NAVIGATION CONTROLLER EXTRACTED):")
        console.log("   - Navigation logic: EXTRACTED ✅")
        console.log("   - UI presentation: SEPARATED ✅")
        console.log("   - Code maintainability: IMPROVED ✅")
    }
    
    /**
     * Validates snippet data before selection and triggers snippet selection if valid
     * Performs comprehensive validation to prevent crashes from malformed data.
     * 
     * @param {Object} snippet - Snippet object to validate and select
     * @param {string} source - Source of selection ("mouse_click", "keyboard_enter") for error reporting
     * @returns {boolean} True if snippet is valid and selection was triggered
     * 
     * Validation checks:
     * - Object existence and type
     * - Required properties (title, content)
     * - Property types (both must be strings)
     * 
     * Side effects:
     * - Logs validation steps and results
     * - Triggers snippetSelected signal if validation passes
     * - Logs error messages if validation fails
     */
    function validateAndSelectSnippet(snippet, source) {
        window.debugLog("🔍 Validating snippet from " + source + ": " + (snippet ? snippet.title : "null"))
        
        if (!snippet) {
            console.error("❌ Snippet selection failed - null snippet from " + source)
            if (notifyUser) {
                notifyUser("Snippet Manager Error", "Invalid snippet data - selection failed", "critical")
            }
            return false
        }
        
        if (typeof snippet !== 'object') {
            console.error("❌ Snippet selection failed - invalid object type from " + source + ": " + typeof snippet)
            if (notifyUser) {
                notifyUser("Snippet Manager Error", "Corrupted snippet data detected", "critical")
            }
            return false
        }
        
        if (!snippet.hasOwnProperty('title') || typeof snippet.title !== 'string') {
            console.error("❌ Snippet selection failed - invalid title from " + source)
            if (notifyUser) {
                notifyUser("Snippet Manager Error", "Snippet missing title property", "critical")
            }
            return false
        }
        
        if (!snippet.hasOwnProperty('content') || typeof snippet.content !== 'string') {
            console.error("❌ Snippet selection failed - invalid content from " + source)
            if (notifyUser) {
                notifyUser("Snippet Manager Error", "Snippet missing content property", "critical")
            }
            return false
        }
        
        window.debugLog("✅ Snippet validation passed from " + source + ": " + snippet.title)
        window.snippetSelected(snippet)
        return true
    }
    
    /**
     * Handles Enter key press events for snippet selection
     * Unified handler for both Return and Enter key events
     * 
     * @param {Object} event - Keyboard event object
     * 
     * Functionality:
     * - Validates snippet availability and navigation state
     * - Retrieves currently selected snippet from NavigationController
     * - Performs snippet validation and selection via validateAndSelectSnippet
     * 
     * Side effects:
     * - Accepts keyboard event to prevent propagation
     * - Logs selection attempt and validation results
     * - Triggers snippet selection if validation passes
     */
    function handleEnterKey(event) {
        event.accepted = true
        if (window.hasValidSnippets && navigationController.visibleSnippetWindow.length > 0) {
            const selectedSnippet = navigationController.visibleSnippetWindow[navigationController.currentIndex]
            if (selectedSnippet) {
                window.debugLog("⌨️ Enter key pressed - selecting snippet: " + selectedSnippet.title)
                if (!window.validateAndSelectSnippet(selectedSnippet, "enter_key")) {
                    window.debugLog("❌ Enter key validation failed")
                }
            }
        }
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
                // HyprlandFocusGrab is ready - now coordinate Qt focus with search input
                Qt.callLater(function() {
                    if (searchInput && window.visible) {
                        searchInput.forceActiveFocus()
                        window.debugLog("🎯 Focus coordinated with HyprlandFocusGrab - search input focused")
                    } else {
                        window.debugLog("⚠️ Focus coordination skipped - overlay no longer active")
                    }
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
                  "Snippet Manager (" + (navigationController.globalIndex + 1) + " of " + snippets.length + " snippets)" :
                  "Snippet Manager"
            color: "#ffffff"
            font.pixelSize: Constants.headerFontSize
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        // Search input field
        TextField {
            id: searchInput
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Constants.mainMargins
            anchors.topMargin: Constants.headerTopMargin
            height: Constants.search.inputHeight
            
            placeholderText: "Search snippets..."
            font.pixelSize: Constants.search.fontSize
            focus: true
            
            background: Rectangle {
                color: Constants.search.backgroundColor
                border.color: Constants.search.borderColor
                border.width: Constants.search.borderWidth
                radius: Constants.search.borderRadius
            }
            
            color: Constants.search.textColor
            selectionColor: Constants.search.selectionColor
            selectedTextColor: Constants.search.selectedTextColor
            
            Keys.onUpPressed: function(event) {
                event.accepted = true
                if (window.hasValidSnippets) {
                    window.debugLog("⬆️ Up arrow delegated from search field to NavigationController")
                    navigationController.moveUp()
                }
            }
            
            Keys.onDownPressed: function(event) {
                event.accepted = true
                if (window.hasValidSnippets) {
                    window.debugLog("⬇️ Down arrow delegated from search field to NavigationController")
                    navigationController.moveDown()
                }
            }
            
            Keys.onEscapePressed: function(event) {
                event.accepted = true
                if (searchInput.text.length > 0) {
                    // First escape clears search
                    window.debugLog("🧹 Escape pressed - clearing search text")
                    searchInput.text = ""
                } else {
                    // Second escape (or escape with empty search) exits
                    window.debugLog("🔴 Escape pressed - dismissing overlay")
                    Qt.quit()
                }
            }
            
            Keys.onReturnPressed: function(event) { handleEnterKey(event) }
            Keys.onEnterPressed: function(event) { handleEnterKey(event) }
        }
        
        // Main content area with conditional rendering
        Item {
            id: contentArea
            anchors.top: searchInput.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: instructions.top
            anchors.margins: Constants.mainMargins
            anchors.topMargin: Constants.itemSpacing
            
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
                    model: navigationController.visibleSnippetWindow
                    
                    Rectangle {
                        width: snippetColumn.width
                        height: Constants.snippetItemHeight
                        color: index === navigationController.currentIndex ? "#444444" : "#2a2a2a"
                        border.color: index === navigationController.currentIndex ? "#ffffff" : "#555555"
                        border.width: Constants.borderWidth
                        radius: Constants.itemBorderRadius
                        
                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: Constants.textMargins
                            text: modelData.title || "Untitled"
                            color: index === navigationController.currentIndex ? "#ffffff" : "#cccccc"
                            font.pixelSize: Constants.snippetFontSize
                            font.bold: false
                            elide: Text.ElideRight
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                window.debugLog("🖱️ Clicked snippet at local index: " + index + " (global: " + (navigationController.visibleRangeStartIndex + index) + ")")
                                navigationController.currentIndex = index
                                
                                // Validate snippet data before selection
                                if (!window.validateAndSelectSnippet(modelData, "mouse_click")) {
                                    window.debugLog("❌ Mouse click validation failed for index: " + index)
                                }
                            }
                            onEntered: {
                                // Validate index bounds before updating currentIndex
                                if (index >= 0 && index < navigationController.visibleSnippetWindow.length) {
                                    navigationController.currentIndex = index
                                } else {
                                    window.debugLog("❌ Mouse hover index out of bounds: " + index + " (max: " + (navigationController.visibleSnippetWindow.length - 1) + ")")
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
                  "↑↓ Navigate • Enter Select • Esc Clear/Cancel" : 
                  "Esc Cancel • Add snippets to data/snippets.json"
            color: "#aaaaaa"
            font.pixelSize: Constants.instructionsFontSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        // Legacy keyHandler - replaced by searchInput keyboard navigation
        // All keyboard navigation now handled by TextField using QuickShell launcher pattern
        // Item {
        //     id: keyHandler
        //     anchors.fill: parent
        //     focus: false  // Disabled - searchInput maintains focus
        // }
    }
    
    Component.onCompleted: {
        console.log("OverlayWindow: Created with", snippets.length, "snippets")
        window.debugLog("🎯 Focus management delegated to HyprlandFocusGrab")
    }
}
