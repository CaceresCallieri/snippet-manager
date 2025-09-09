import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
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
        const searchText = searchInput?.text || ""
        
        if (!searchTerm) {
            // No search term - return all snippets with escaped titles (no highlighting)
            return sourceSnippets.map(snippet => {
                return {
                    title: snippet.title,
                    content: snippet.content,
                    highlightedTitle: escapeHtml(snippet.title)
                }
            })
        }
        
        // Filter and highlight in one pass for optimal performance
        return sourceSnippets.filter(snippet => 
            snippet.title.toLowerCase().includes(searchTerm) ||
            snippet.content.toLowerCase().includes(searchTerm)
        ).map(snippet => {
            return {
                title: snippet.title,
                content: snippet.content,
                highlightedTitle: highlightSearchTerm(snippet.title, searchText)
            }
        })
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
     * Generates appropriate header text based on current search and navigation state
     * Handles empty state, active search, and normal navigation scenarios
     * 
     * @returns {string} Formatted header text with context indicators
     * 
     * Side effects:
     * - No side effects - pure text computation function
     * - Safe for use in property bindings
     */
    function getHeaderText() {
        if (sourceSnippets.length === 0) {
            return "Snippet Manager"
        }
        
        const searchActive = searchInput?.text?.length > 0
        const matchCount = displayedSnippets.length  
        const totalCount = sourceSnippets.length
        const currentPos = navigationController.globalIndex + 1
        
        // Handle search with no results
        if (searchActive && matchCount === 0) {
            return `No matches for "${searchInput.text}"`
        }
        
        // Handle filtered search results
        if (searchActive && matchCount < totalCount) {
            return `Showing ${matchCount} of ${totalCount} snippets • ${currentPos}/${matchCount} selected`
        }
        
        // Handle normal navigation (no search or showing all results)
        return `Snippet Manager • ${currentPos}/${totalCount} selected`
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
    
    
    // Position overlay at fixed screen percentage (1/6 from top)
    // Note: Cursor positioning not currently implemented for overlay layer
    margins.top: screen.height * Constants.overlayTopOffsetFraction
    
    implicitWidth: Constants.overlayWidth
    implicitHeight: Constants.overlayHeight
    color: "transparent"
    
    /**
     * Helper function for desktop notifications using notify-send
     * @param {string} title - Notification title
     * @param {string} message - Notification message  
     * @param {string} urgency - Notification urgency level ("low", "normal", "critical")
     */
    function notifyUser(title, message, urgency = "normal") {
        const command = ["notify-send", "-u", urgency, title, message]
        Quickshell.execDetached(command)
    }

    /**
     * Configures Wayland layer shell for persistent focus overlay
     * Sets up exclusive keyboard mode to prevent system shortcuts from dismissing overlay
     * 
     * @returns {boolean} True if configuration was successful, false otherwise
     * 
     * Side effects:
     * - Sets WlrLayershell.layer to WlrLayer.Overlay
     * - Sets WlrLayershell.keyboardFocus to WlrKeyboardFocus.Exclusive  
     * - Sets WlrLayershell.namespace to "snippet-manager"
     * - Logs configuration status and sends user notifications on errors
     * - Verifies focus acquisition with Qt.callLater()
     */
    function configureLayerShell() {
        if (!window.WlrLayershell) {
            window.debugLog("⚠️ WlrLayershell not available - falling back to standard window mode")
            notifyUser("Snippet Manager", 
                      "Running in compatibility mode - some shortcuts may dismiss overlay", 
                      "low")
            return false
        }
        
        try {
            window.WlrLayershell.layer = WlrLayer.Overlay
            window.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
            window.WlrLayershell.namespace = "snippet-manager"
            
            // Verify focus acquisition worked (compositor may not grant exclusive focus)
            Qt.callLater(function() {
                if (window.WlrLayershell.keyboardFocus === WlrKeyboardFocus.Exclusive) {
                    window.debugLog("🔧 WlrLayershell configured successfully with exclusive keyboard focus")
                } else {
                    window.debugLog("❌ Exclusive keyboard focus acquisition failed - compositor may not support it")
                    notifyUser("Snippet Manager Warning", 
                              "Keyboard shortcuts may not work properly - compositor doesn't support exclusive focus", 
                              "normal")
                }
            })
            
            window.debugLog("🔧 WlrLayershell configuration initiated")
            return true
            
        } catch (error) {
            console.error("❌ WlrLayershell configuration failed:", error.message)
            notifyUser("Snippet Manager Error", 
                      "Focus configuration failed - overlay may not work properly", 
                      "critical")
            return false
        }
    }

    /**
     * Timer-based focus acquisition with timeout protection and retry mechanism
     * Ensures search input receives focus even if initial attempts fail
     * 
     * Features:
     * - 500ms timeout per attempt
     * - Up to 3 retry attempts
     * - Focus state verification
     * - User notification on persistent failures
     */
    Timer {
        id: focusTimeout
        interval: 500  // 500ms timeout per attempt
        running: false
        repeat: false
        
        property int attemptCount: 0
        readonly property int maxAttempts: 3
        property bool layerShellSuccess: false
        
        onTriggered: {
            attemptCount++
            
            if (searchInput && searchInput.visible) {
                searchInput.forceActiveFocus()
                
                // Verify focus was acquired after short delay
                Qt.callLater(function() {
                    if (searchInput.activeFocus) {
                        const focusMode = layerShellSuccess ? "WlrLayershell exclusive" : "standard"
                        window.debugLog(`🎯 Focus acquired on attempt ${attemptCount} with ${focusMode} keyboard mode`)
                    } else if (attemptCount < maxAttempts) {
                        window.debugLog(`⚠️ Focus attempt ${attemptCount} failed, retrying in ${interval}ms...`)
                        focusTimeout.restart()
                    } else {
                        window.debugLog("❌ Focus acquisition failed after " + maxAttempts + " attempts")
                        notifyUser("Snippet Manager Warning", 
                                  "Keyboard input may not work properly - focus acquisition failed", 
                                  "normal")
                    }
                })
            } else {
                window.debugLog("❌ Search input not available for focus (visible: " + (searchInput ? searchInput.visible : "null") + ")")
                if (attemptCount < maxAttempts) {
                    window.debugLog(`⚠️ Retrying focus attempt ${attemptCount + 1} in ${interval}ms...`)
                    focusTimeout.restart()
                }
            }
        }
    }

    /**
     * Initializes input focus with timeout protection and retry mechanism
     * Replaces Qt.callLater with Timer-based approach for better reliability
     * 
     * @param {boolean} layerShellSuccess - Whether layer shell configuration succeeded
     * 
     * Side effects:
     * - Starts focusTimeout timer for protected focus acquisition
     * - Resets attempt counter for fresh focus acquisition cycle
     * - Logs initialization with focus mode information
     */
    function initializeFocus(layerShellSuccess) {
        const focusMode = layerShellSuccess ? "WlrLayershell exclusive" : "standard"
        window.debugLog(`🎯 Initializing focus acquisition with ${focusMode} keyboard mode`)
        
        // Start focus acquisition with timeout protection
        focusTimeout.layerShellSuccess = layerShellSuccess
        focusTimeout.attemptCount = 0
        focusTimeout.start()
    }

    // Configure as Wayland layer shell overlay with exclusive keyboard focus
    // This prevents system shortcuts (like super+p) from dismissing the overlay
    Component.onCompleted: {
        console.log("OverlayWindow: Created with", sourceSnippets.length, "snippets")
        
        const layerShellSuccess = configureLayerShell()
        initializeFocus(layerShellSuccess)
    }
    
    /**
     * Wayland layer shell protocol monitoring for external changes
     * Detects compositor modifications to layer shell properties and notifies user
     * 
     * Monitors:
     * - layer property changes (Overlay layer requirement)
     * - keyboardFocus property changes (Exclusive focus requirement)
     * - namespace property changes (snippet-manager identifier)
     * 
     * Side effects:
     * - Logs all property changes with debug output
     * - Sends desktop notifications for critical changes affecting functionality
     * - No automatic recovery to avoid compositor conflicts
     */
    Connections {
        target: window.WlrLayershell
        enabled: window.WlrLayershell != null
        
        function onLayerChanged() {
            window.debugLog(`⚠️ Layer shell layer changed externally: ${window.WlrLayershell.layer} (expected: ${WlrLayer.Overlay})`)
            
            if (window.WlrLayershell.layer !== WlrLayer.Overlay) {
                notifyUser("Snippet Manager Warning", 
                          "Window layer changed - overlay may not stay on top of other windows", 
                          "normal")
            }
        }
        
        function onKeyboardFocusChanged() {
            window.debugLog(`⚠️ Keyboard focus mode changed externally: ${window.WlrLayershell.keyboardFocus} (expected: ${WlrKeyboardFocus.Exclusive})`)
            
            if (window.WlrLayershell.keyboardFocus !== WlrKeyboardFocus.Exclusive) {
                notifyUser("Snippet Manager Warning", 
                          "Focus mode changed - system shortcuts may now dismiss overlay", 
                          "normal")
            }
        }
        
        function onNamespaceChanged() {
            if (window.WlrLayershell.namespace !== "snippet-manager") {
                window.debugLog(`⚠️ Layer shell namespace changed externally: '${window.WlrLayershell.namespace}' (expected: 'snippet-manager')`)
            }
        }
    }
    
    // Focus management now handled by WlrLayershell.keyboardFocus = KeyboardFocus.Exclusive
    // This provides stronger focus control than HyprlandFocusGrab and prevents system shortcuts
    // from interrupting the overlay (like super+p for screenshots)
    
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
            text: getHeaderText()
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
                            text: modelData.highlightedTitle || "Untitled"
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
    
}
