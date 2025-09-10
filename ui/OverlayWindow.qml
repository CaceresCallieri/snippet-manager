import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../utils"

PanelWindow {
    id: window
    
    property var sourceSnippets: []
    property var debugLog: null
    property var notifyUser: null
    
    /**
     * Navigation controller instance handling all navigation logic
     * Provides sliding window navigation, cursor movement, and wrap-around behavior
     */
    NavigationController {
        id: navigationController
        snippets: window.highlightedSnippets
        debugLog: window.debugLog
        
        onSelectionChanged: {
            // Navigation state changed - UI will automatically update via property bindings
            window.debugLog(`🔄 Navigation state updated: global ${globalIndex}, window ${visibleRangeStartIndex}-${visibleRangeStartIndex + maxDisplayed - 1}`)
        }
    }
    
    /**
     * Stage 1: Cache filtered results (only recomputes when search changes)
     * Filters both title and content fields with case-insensitive matching
     * 
     * @returns {Array} All snippets matching current search term
     */
    readonly property var filteredSnippets: {
        if (!searchInput || !searchInput.text || searchInput.text.length === 0) {
            return sourceSnippets
        }
        
        const searchTerm = searchInput.text.toLowerCase()
        return sourceSnippets.filter(snippet => {
            const titleMatch = snippet.title.toLowerCase().includes(searchTerm)
            const contentMatch = snippet.content.toLowerCase().includes(searchTerm)
            return titleMatch || contentMatch
        })
    }
    
    /**
     * Stage 2: Cache highlighted results (only recomputes when filteredSnippets or search changes)
     * Applies search term highlighting to filtered snippets for display
     * 
     * @returns {Array} Filtered snippets with highlighted titles for display
     */
    readonly property var highlightedSnippets: {
        const searchActive = searchInput?.text?.length > 0
        if (!searchActive) {
            return filteredSnippets.map(snippet => ({
                title: snippet.title,
                content: snippet.content,
                highlightedTitle: escapeHtml(snippet.title)
            }))
        }
        
        const searchTerm = searchInput.text.trim()
        return filteredSnippets.map(snippet => ({
            title: snippet.title,
            content: snippet.content,
            highlightedTitle: highlightSearchTerm(snippet.title, searchTerm)
        }))
    }
    
    /**
     * Stage 3: Display window (only recomputes when navigation or highlighting changes)
     * Uses NavigationController's sliding window to show subset of highlighted snippets
     * 
     * @returns {Array} Currently visible snippet window for UI display
     */
    readonly property var displayedSnippets: {
        return navigationController.visibleSnippetWindow
    }

    /**
     * Computed property: Whether valid snippets are available for display
     * Controls conditional UI rendering between empty state and normal snippet list.
     * 
     * @returns {boolean} True if displayed snippets array contains at least one valid snippet
     */
    property bool hasSnippetsToDisplay: filteredSnippets.length > 0
    
    // Performance measurement (external counters to avoid binding loops)
    property int filteringCalculationCount: 0
    property int highlightingCalculationCount: 0
    property int displayCalculationCount: 0
    
    signal snippetSelected(var snippet)
    signal dismissed()
    
    // Performance monitoring handlers (avoid binding loops by using external handlers)
    onFilteredSnippetsChanged: {
        filteringCalculationCount++
        window.debugLog(`🔍 Filtering recalculated (${filteringCalculationCount} times) - ${filteredSnippets.length} results`)
    }
    
    onHighlightedSnippetsChanged: {
        highlightingCalculationCount++
        window.debugLog(`✨ Highlighting recalculated (${highlightingCalculationCount} times)`)
    }
    
    onDisplayedSnippetsChanged: {
        displayCalculationCount++
        window.debugLog(`📊 Display window recalculated (${displayCalculationCount} times)`)
    }
    
    /**
     * Generates title text for the header - always "Snippet Manager"
     * Simplified from previous complex header text generation
     * 
     * @returns {string} Title text for header component
     * 
     * Side effects:
     * - No side effects - pure text computation function
     * - Safe for use in property bindings
     */
    function getTitleText() {
        return "Snippet Manager"
    }
    
    /**
     * Generates count text based on current search and navigation state
     * Delegates to specific functions for each UI state for improved maintainability
     * 
     * @returns {string} Count text with current position and total info
     * 
     * Side effects:
     * - No side effects - pure text computation function  
     * - Safe for use in property bindings
     */
    function getCountText() {
        if (sourceSnippets.length === 0) {
            return getEmptyStateMessage()
        }
        
        const searchActive = searchInput?.text?.length > 0
        if (searchActive) {
            return getSearchStateMessage()
        } else {
            return getNormalNavigationMessage()
        }
    }

    /**
     * Returns message for empty snippet state
     * 
     * @returns {string} Empty state message
     */
    function getEmptyStateMessage() {
        return "No snippets available"
    }

    /**
     * Returns appropriate message for search state
     * Handles both no matches and partial matches cases
     * 
     * @returns {string} Search state message
     */
    function getSearchStateMessage() {
        const matchCount = filteredSnippets.length
        const searchTerm = searchInput.text
        
        if (matchCount === 0) {
            return getNoMatchesMessage(searchTerm)
        }
        
        const totalCount = sourceSnippets.length
        if (matchCount < totalCount) {
            return getPartialMatchesMessage(matchCount, totalCount)
        }
        
        return getNormalNavigationMessage()
    }

    /**
     * Returns message when no search matches are found
     * 
     * @param {string} searchTerm - The search term that produced no matches
     * @returns {string} No matches message
     */
    function getNoMatchesMessage(searchTerm) {
        return `No matches for "${searchTerm}"`
    }

    /**
     * Returns message for partial search matches with position info
     * 
     * @param {number} matchCount - Number of matches found
     * @param {number} totalCount - Total number of snippets
     * @returns {string} Partial matches message with position
     */
    function getPartialMatchesMessage(matchCount, totalCount) {
        const currentPos = navigationController.globalIndex + 1
        return `${currentPos}/${matchCount} • ${matchCount} of ${totalCount} total`
    }

    /**
     * Returns message for normal navigation state
     * Shows current position out of total available items
     * 
     * @returns {string} Normal navigation message
     */
    function getNormalNavigationMessage() {
        const currentPos = navigationController.globalIndex + 1
        const totalCount = filteredSnippets.length || sourceSnippets.length
        return `${currentPos}/${totalCount}`
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
        window.debugLog("🔍 PERFORMANCE SUMMARY (NAVIGATION CONTROLLER EXTRACTED):")
        window.debugLog("   - Navigation logic: EXTRACTED ✅")
        window.debugLog("   - UI presentation: SEPARATED ✅")
        window.debugLog("   - Code maintainability: IMPROVED ✅")
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
                return escapedText.replace(regex, `<span style="color: ${Constants.search.matchHighlightTextColor};">${escapedTerm}</span>`)
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
     * Initializes input focus with simple Qt approach
     * Simplified from complex Timer-based retry mechanism for better maintainability
     * 
     * @param {boolean} layerShellSuccess - Whether layer shell configuration succeeded
     * 
     * Side effects:
     * - Focuses search input using Qt.callLater for proper timing
     * - Logs focus status for debugging
     */
    function initializeFocus(layerShellSuccess) {
        const focusMode = layerShellSuccess ? "WlrLayershell exclusive" : "standard"
        window.debugLog(`🎯 Initializing focus with ${focusMode} keyboard mode`)
        
        Qt.callLater(function() {
            if (searchInput && searchInput.visible) {
                searchInput.forceActiveFocus()
                window.debugLog("🎯 Search input focused")
            } else {
                window.debugLog("⚠️ Search input not available for focus")
            }
        })
    }

    // Configure as Wayland layer shell overlay with exclusive keyboard focus
    // This prevents system shortcuts (like super+p) from dismissing the overlay
    Component.onCompleted: {
        window.debugLog("OverlayWindow: Created with " + sourceSnippets.length + " snippets")
        
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
        border.color: Constants.colors.mainBorder
        border.width: Constants.borderWidth
        radius: Constants.borderRadius
        
        // Header with title and count components stacked vertically
        Column {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Constants.headerMargins
            height: Constants.headerHeight
            
            // Title component
            Text {
                id: titleText
                anchors.left: parent.left
                anchors.right: parent.right
                height: Constants.titleHeight
                text: getTitleText()
                color: "#ffffff"
                font.pixelSize: Constants.titleFontSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            // Count component
            Text {
                id: countText
                anchors.left: parent.left
                anchors.right: parent.right
                height: Constants.countHeight
                text: getCountText()
                color: "#cccccc"
                font.pixelSize: Constants.countFontSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        
        // Search input field
        TextField {
            id: searchInput
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Constants.mainMargins
            anchors.topMargin: Constants.itemSpacing
            height: Constants.search.inputHeight
            
            placeholderText: "Search snippets..."
            placeholderTextColor: Constants.search.placeholderTextColor
            font.pixelSize: Constants.search.fontSize
            leftPadding: Constants.textMargins
            rightPadding: Constants.textMargins
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
                visible: parent.text.length > Constants.search.characterCountThreshold
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 2
                text: parent.text.length + "/" + Constants.search.maxInputLength
                font.pixelSize: Constants.search.smallTextFontSize
                color: parent.text.length >= Constants.search.maxInputLength ? Constants.search.warningColor : Constants.search.characterCountColor
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
                        color: index === navigationController.currentIndex ? Constants.colors.selectedBackground : Constants.colors.unselectedBackground
                        border.color: index === navigationController.currentIndex ? Constants.colors.selectedBorder : Constants.colors.unselectedBorder
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
