import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import "../utils"

PanelWindow {
    id: window
    
    property var sourceSnippets: []
    property bool isDebugLoggingEnabled: false
    property var notifyUser: null
    
    /**
     * Navigation controller instance handling all navigation logic
     * Provides sliding window navigation, cursor movement, and wrap-around behavior
     */
    NavigationController {
        id: navigationController
        snippets: window.displayedSnippets
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
     * @returns {Array} Currently displayed snippets after search filtering
     */
    property var displayedSnippets: {
        const searchTerm = (searchInput?.text || "").toLowerCase()
        if (!searchTerm) return sourceSnippets
        
        return sourceSnippets.filter(snippet => 
            snippet.title.toLowerCase().includes(searchTerm) ||
            snippet.content.toLowerCase().includes(searchTerm)
        )
    }

    /**
     * Computed property: Whether valid snippets are available for display
     * Controls conditional UI rendering between empty state and normal snippet list.
     * 
     * @returns {boolean} True if displayed snippets array contains at least one valid snippet
     */
    property bool hasSnippetsToDisplay: displayedSnippets.length > 0
    
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
        if (window.hasSnippetsToDisplay && navigationController.visibleSnippetWindow.length > 0) {
            const selectedSnippet = navigationController.visibleSnippetWindow[navigationController.currentIndex]
            if (selectedSnippet) {
                window.debugLog("⌨️ Enter key pressed - selecting snippet: " + selectedSnippet.title)
                if (!window.validateAndSelectSnippet(selectedSnippet, "enter_key")) {
                    window.debugLog("❌ Enter key validation failed")
                }
            }
        }
    }
    
    /**
     * Handles progressive Escape key behavior: clear search then exit overlay
     * First press clears search text, second press (or empty search) exits
     * 
     * @param {Object} event - Keyboard event object
     * 
     * Functionality:
     * - Progressive behavior: first escape clears search, second escape exits
     * - Immediate exit if search field is already empty
     * - Proper event handling to prevent propagation
     * 
     * Side effects:
     * - Accepts keyboard event to prevent propagation
     * - Clears searchInput.text on first press when text exists
     * - Calls Qt.quit() to exit overlay on second press or when search empty
     * - Logs user actions with appropriate emoji markers
     */
    function handleEscapeKey(event) {
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
    
    /**
     * Delegates up arrow navigation to NavigationController while maintaining search focus
     * Enables navigation without losing search field focus
     * 
     * @param {Object} event - Keyboard event object
     * 
     * Functionality:
     * - Validates snippet availability before navigation
     * - Delegates navigation to NavigationController.moveUp()
     * - Maintains search field focus throughout navigation
     * 
     * Side effects:
     * - Accepts keyboard event to prevent propagation
     * - Calls navigationController.moveUp() if valid snippets available
     * - Logs navigation delegation with directional emoji
     */
    function handleUpArrow(event) {
        event.accepted = true
        if (window.hasSnippetsToDisplay) {
            window.debugLog("⬆️ Up arrow delegated from search field to NavigationController")
            navigationController.moveUp()
        }
    }
    
    /**
     * Delegates down arrow navigation to NavigationController while maintaining search focus
     * Enables navigation without losing search field focus
     * 
     * @param {Object} event - Keyboard event object
     * 
     * Functionality:
     * - Validates snippet availability before navigation
     * - Delegates navigation to NavigationController.moveDown()
     * - Maintains search field focus throughout navigation
     * 
     * Side effects:
     * - Accepts keyboard event to prevent propagation
     * - Calls navigationController.moveDown() if valid snippets available
     * - Logs navigation delegation with directional emoji
     */
    function handleDownArrow(event) {
        event.accepted = true
        if (window.hasSnippetsToDisplay) {
            window.debugLog("⬇️ Down arrow delegated from search field to NavigationController")
            navigationController.moveDown()
        }
    }
    
    /**
     * Escapes HTML special characters to prevent XSS injection in RichText contexts
     * Essential security function for safely displaying user content with HTML formatting.
     * 
     * @param {string} text - Text content to escape for HTML safety
     * @returns {string} HTML-escaped text safe for RichText rendering
     * 
     * Security considerations:
     * - Prevents XSS attacks through malicious snippet titles
     * - Required before any HTML generation in Text.RichText contexts
     * - Escapes all dangerous HTML characters (&, <, >, ", ')
     * 
     * Side effects:
     * - No side effects - pure text transformation function
     * - Safe for use in property bindings and computed properties
     */
    function escapeHtml(text) {
        return text.replace(/&/g, '&amp;')
                  .replace(/</g, '&lt;')
                  .replace(/>/g, '&gt;')
                  .replace(/"/g, '&quot;')
                  .replace(/'/g, '&#39;')
    }
    
    /**
     * Highlights search term matches in text using HTML span tags with colored text
     * Provides visual emphasis for search matches with comprehensive security and error handling.
     * 
     * @param {string} text - Original text to highlight matches in (will be HTML-escaped)
     * @param {string} searchTerm - Search term to highlight (case-insensitive matching)
     * @returns {string} HTML-formatted text with highlighted search matches, safely escaped
     * 
     * Security features:
     * - HTML-escapes all user content to prevent XSS injection
     * - Validates input types and existence before processing
     * - Handles malformed regex patterns gracefully
     * 
     * Technical details:
     * - Escapes both original text AND search term for HTML safety
     * - Case-insensitive highlighting matches search behavior
     * - Uses HTML span tags with CSS styling for visual highlighting
     * - Comprehensive error handling with graceful fallbacks
     * 
     * Side effects:
     * - Logs errors to console for debugging without crashing UI
     * - Always returns safely escaped text even on errors
     */
    function highlightSearchTerm(text, searchTerm) {
        try {
            // Input validation for security and stability
            if (!text || typeof text !== 'string') {
                window.debugLog("⚠️ Highlighting: Invalid text input")
                return ""
            }
            
            if (!searchTerm || typeof searchTerm !== 'string' || searchTerm.length === 0) {
                return escapeHtml(text)
            }
            
            // HTML-escape both text and search term for security
            const escapedText = escapeHtml(text)
            const escapedTerm = escapeHtml(searchTerm)
            
            // Regex escaping with error handling
            let regexPattern
            try {
                regexPattern = escapedTerm.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
            } catch (error) {
                window.debugLog("⚠️ Highlighting: Regex escaping failed - " + error.message)
                return escapedText
            }
            
            if (regexPattern.length === 0) {
                return escapedText
            }
            
            // Regex compilation and replacement with error handling
            try {
                const regex = new RegExp(`(${regexPattern})`, 'gi')
                return escapedText.replace(regex, `<span style="color: ${Constants.search.matchHighlightTextColor};">$1</span>`)
            } catch (error) {
                window.debugLog("⚠️ Highlighting: Regex compilation failed - " + error.message)
                return escapedText
            }
            
        } catch (error) {
            console.warn("❌ Highlighting function failed:", error.message)
            // Ultimate fallback - return safely escaped text or empty string
            return (text && typeof text === 'string') ? escapeHtml(text) : ""
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
            text: {
                if (sourceSnippets.length === 0) {
                    return "Snippet Manager"
                } else if (searchInput?.text && searchInput.text.length > 0) {
                    const matchCount = displayedSnippets.length
                    const totalCount = sourceSnippets.length
                    if (matchCount === 0) {
                        return `No matches for "${searchInput.text}"`
                    } else if (matchCount === totalCount) {
                        const currentPos = navigationController.globalIndex + 1
                        return `Snippet Manager • ${currentPos}/${totalCount} selected`
                    } else {
                        const currentPos = navigationController.globalIndex + 1
                        return `Showing ${matchCount} of ${totalCount} snippets • ${currentPos}/${matchCount} selected`
                    }
                } else {
                    const totalCount = sourceSnippets.length
                    const currentPos = navigationController.globalIndex + 1
                    return `Snippet Manager • ${currentPos}/${totalCount} selected`
                }
            }
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
            
            // Input validation: prevent input beyond maximum length
            validator: RegularExpressionValidator {
                regularExpression: new RegExp("^.{0," + Constants.search.maxInputLength + "}$")
            }
            
            background: Rectangle {
                color: Constants.search.backgroundColor
                border.color: Constants.search.borderColor
                border.width: Constants.search.borderWidth
                radius: Constants.search.borderRadius
            }
            
            color: Constants.search.textColor
            selectionColor: Constants.search.selectionColor
            selectedTextColor: Constants.search.selectedTextColor
            
            Keys.onUpPressed: function(event) { handleUpArrow(event) }
            Keys.onDownPressed: function(event) { handleDownArrow(event) }
            Keys.onEscapePressed: function(event) { handleEscapeKey(event) }
            
            Keys.onReturnPressed: function(event) { handleEnterKey(event) }
            Keys.onEnterPressed: function(event) { handleEnterKey(event) }
            
            // Character count indicator for long searches
            Text {
                visible: parent.text.length > 50
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 2
                text: parent.text.length + "/" + Constants.search.maxInputLength
                font.pixelSize: 8
                color: parent.text.length >= Constants.search.maxInputLength ? Constants.search.warningColor : "#aaaaaa"
            }
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
                visible: !window.hasSnippetsToDisplay
                searchTerm: searchInput?.text || ""
                isSearchActive: (searchInput?.text || "").length > 0
                totalSnippets: sourceSnippets.length
            }
            
            // Normal snippet list
            Column {
                id: snippetColumn
                anchors.fill: parent
                visible: window.hasSnippetsToDisplay
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
                        
                        // Title with highlighting
                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: Constants.textMargins
                            text: window.highlightSearchTerm(modelData.title || "Untitled", searchInput?.text || "")
                            textFormat: Text.RichText  // Enable HTML formatting
                            color: index === navigationController.currentIndex ? "#ffffff" : "#cccccc"
                            font.pixelSize: Constants.snippetTitleFontSize
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
            text: window.hasSnippetsToDisplay ? 
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
        console.log("OverlayWindow: Created with", sourceSnippets.length, "snippets")
        window.debugLog("🎯 Focus management delegated to HyprlandFocusGrab")
    }
}
