import QtQuick
import "../utils"

/**
 * Navigation Controller for Snippet Manager
 * 
 * Provides sliding window navigation logic extracted from OverlayWindow.qml.
 * Implements VS Code-style navigation where a fixed number of items are displayed
 * while users can navigate through the full collection with smooth scrolling.
 * 
 * Features:
 * - Sliding window navigation (displays subset, navigates full collection)
 * - Within-window cursor movement (fast local navigation)
 * - Window scrolling (smooth sliding when at boundaries)
 * - Wrap-around navigation (infinite scrolling feel)
 * - Comprehensive bounds checking and edge case handling
 * 
 * Usage:
 * ```qml
 * NavigationController {
 *     id: navController
 *     snippets: mySnippetsArray
 *     maxDisplayed: 5
 *     onSelectionChanged: updateUI()
 * }
 * ```
 */
QtObject {
    id: controller
    
    // ============================================================================
    // PUBLIC PROPERTIES
    // ============================================================================
    
    /**
     * Complete array of snippet objects to navigate through
     * Expected format: [{title: string, content: string}, ...]
     */
    property var snippets: []
    
    /**
     * Current cursor position within the visible window (0-based local index)
     * Range: 0 to min(maxDisplayed-1, visibleSnippetWindow.length-1)
     */
    property int currentIndex: 0
    
    /**
     * Starting index of the visible window in the full snippets array
     * Controls which subset of snippets is currently displayed
     */
    property int visibleRangeStartIndex: 0
    
    /**
     * Maximum number of snippets to display simultaneously
     * Defines the size of the sliding window
     */
    property int maxDisplayed: Constants.maxVisibleSnippets
    
    /**
     * Debug logging enable/disable flag
     * When true, outputs comprehensive navigation state information
     */
    property bool isDebugLoggingEnabled: false
    
    // ============================================================================
    // COMPUTED PROPERTIES
    // ============================================================================
    
    /**
     * Absolute position in the full snippets array
     * Converts local window position (currentIndex) to global array position
     * Essential for snippet selection and state reporting
     * 
     * @returns {number} Zero-based absolute index (visibleRangeStartIndex + currentIndex)
     */
    readonly property int globalIndex: visibleRangeStartIndex + currentIndex
    
    /**
     * Current subset of snippets visible in the sliding window
     * Implements the core sliding window algorithm for efficient display
     * 
     * Performance optimized with pure readonly binding to eliminate binding loops
     * 
     * @returns {Array} Subset of snippets array (max maxDisplayed items) for UI display
     */
    readonly property var visibleSnippetWindow: {
        if (snippets.length === 0) return []
        const end = Math.min(visibleRangeStartIndex + maxDisplayed, snippets.length)
        return snippets.slice(visibleRangeStartIndex, end)
    }
    
    // ============================================================================
    // SIGNALS
    // ============================================================================
    
    /**
     * Emitted whenever navigation state changes (cursor movement, window scrolling, wrapping)
     * UI components should connect to this signal to update display state
     */
    signal selectionChanged()
    
    // ============================================================================
    // DEBUG LOGGING
    // ============================================================================
    
    /**
     * Conditionally logs debug messages with emoji markers
     * Only outputs when debug mode is enabled to keep production output clean
     * 
     * @param {string} message - Debug message to log (should include emoji marker)
     */
    function debugLog(message) {
        if (isDebugLoggingEnabled) {
            console.log("NavigationController: " + message)
        }
    }
    
    // ============================================================================
    // NAVIGATION CONDITION PREDICATES
    // ============================================================================
    
    /**
     * Checks if cursor can move up within the current visible window
     * @returns {boolean} True if currentIndex > 0 (not at top of visible window)
     */
    function canMoveUpWithinWindow() {
        return currentIndex > 0
    }
    
    /**
     * Checks if the visible window can scroll up to show earlier snippets
     * @returns {boolean} True if visibleRangeStartIndex > 0 (more snippets exist above)
     */
    function canScrollWindowUp() {
        return visibleRangeStartIndex > 0
    }
    
    /**
     * Checks if cursor can move down within the current visible window
     * @returns {boolean} True if currentIndex is not at bottom of visible window
     */
    function canMoveDownWithinWindow() {
        return currentIndex < visibleSnippetWindow.length - 1
    }
    
    /**
     * Checks if the visible window can scroll down to show later snippets
     * @returns {boolean} True if more snippets exist below current window
     */
    function canScrollWindowDown() {
        return visibleRangeStartIndex + maxDisplayed < snippets.length
    }
    
    // ============================================================================
    // NAVIGATION ACTION FUNCTIONS
    // ============================================================================
    
    /**
     * Moves cursor up within the current visible window
     * Side effects: Decrements currentIndex, logs debug message
     */
    function moveUpWithinWindow() {
        currentIndex--
        debugLog(`🎯 Moved up within window to index ${currentIndex} (global: ${globalIndex})`)
    }
    
    /**
     * Scrolls the visible window up by one position to show earlier snippets
     * Side effects: Decrements visibleRangeStartIndex (bounded at 0), logs debug message
     */
    function scrollWindowUp() {
        visibleRangeStartIndex = Math.max(0, visibleRangeStartIndex - 1)
        debugLog(`🔄 Scrolled window up, start: ${visibleRangeStartIndex} (global: ${globalIndex})`)
    }
    
    /**
     * Moves cursor down within the current visible window
     * Side effects: Increments currentIndex, logs debug message
     */
    function moveDownWithinWindow() {
        currentIndex++
        debugLog(`🎯 Moved down within window to index ${currentIndex} (global: ${globalIndex})`)
    }
    
    /**
     * Scrolls the visible window down by one position to show later snippets
     * Side effects: Increments visibleRangeStartIndex (bounded), logs debug message
     */
    function scrollWindowDown() {
        visibleRangeStartIndex = Math.min(visibleRangeStartIndex + 1, snippets.length - 1)
        debugLog(`🔄 Scrolled window down, start: ${visibleRangeStartIndex} (global: ${globalIndex})`)
    }
    
    // ============================================================================
    // WRAP-AROUND CALCULATIONS
    // ============================================================================
    
    /**
     * Calculates optimal window and cursor position for wrapping to bottom of list
     * Used when navigating up from the first snippet to jump to the last items
     * Handles edge case where total snippets < maxDisplayed
     * 
     * @returns {Object} Object with windowStart and cursorIndex properties
     * @returns {number} windowStart - Starting index to show last page of snippets
     * @returns {number} cursorIndex - Local cursor position to select last item in window
     * 
     * @example
     * // With 8 snippets, maxDisplayed=5: returns {windowStart: 3, cursorIndex: 4}
     * // With 3 snippets, maxDisplayed=5: returns {windowStart: 0, cursorIndex: 2}
     */
    function calculateBottomWrapPosition() {
        const windowStart = Math.max(0, snippets.length - maxDisplayed)
        const cursorIndex = Math.min(maxDisplayed - 1, snippets.length - 1 - windowStart)
        return { windowStart, cursorIndex }
    }
    
    /**
     * Calculates window and cursor position for wrapping to top of list
     * Used when navigating down from the last snippet to jump to the first items
     * 
     * @returns {Object} Object with windowStart and cursorIndex properties
     * @returns {number} windowStart - Always 0 (show first page)
     * @returns {number} cursorIndex - Always 0 (select first item)
     */
    function calculateTopWrapPosition() {
        return { windowStart: 0, cursorIndex: 0 }
    }
    
    /**
     * Wraps navigation to the bottom of the snippet list
     * Used when navigating up from the absolute top - provides infinite scrolling feel
     * 
     * Side effects:
     * - Sets visibleRangeStartIndex to show last page of snippets
     * - Sets currentIndex to select the last item in the visible window
     * - Logs debug message with new position
     * - Emits selectionChanged signal
     */
    function wrapToBottom() {
        const position = calculateBottomWrapPosition()
        visibleRangeStartIndex = position.windowStart
        currentIndex = position.cursorIndex
        debugLog(`🔄 Wrapped to bottom - window: ${visibleRangeStartIndex}, cursor: ${currentIndex} (global: ${globalIndex})`)
    }
    
    /**
     * Wraps navigation to the top of the snippet list
     * Used when navigating down from the absolute bottom - provides infinite scrolling feel
     * 
     * Side effects:
     * - Sets visibleRangeStartIndex to 0 (show first page)
     * - Sets currentIndex to 0 (select first item)
     * - Logs debug message with new position
     * - Emits selectionChanged signal
     */
    function wrapToTop() {
        const position = calculateTopWrapPosition()
        visibleRangeStartIndex = position.windowStart
        currentIndex = position.cursorIndex
        debugLog(`🔄 Wrapped to top - window: ${visibleRangeStartIndex}, cursor: ${currentIndex} (global: ${globalIndex})`)
    }
    
    // ============================================================================
    // MAIN NAVIGATION INTERFACE
    // ============================================================================
    
    /**
     * Primary up navigation method implementing complete navigation logic
     * Handles within-window movement, window scrolling, and wrap-around behavior
     * 
     * Navigation priority:
     * 1. Move up within visible window (fastest)
     * 2. Scroll window up to show earlier snippets
     * 3. Wrap to bottom of list (infinite scrolling)
     * 
     * Side effects:
     * - Updates navigation state (currentIndex and/or visibleRangeStartIndex)
     * - Logs comprehensive debug information
     * - Emits selectionChanged signal
     */
    function moveUp() {
        if (snippets.length === 0) {
            debugLog("❌ Navigation ignored - no snippets available")
            return
        }
        
        if (canMoveUpWithinWindow()) {
            moveUpWithinWindow()
        } else if (canScrollWindowUp()) {
            scrollWindowUp()
        } else {
            wrapToBottom()
        }
        
        updateNavigationState("UP")
        selectionChanged()
    }
    
    /**
     * Primary down navigation method implementing complete navigation logic
     * Handles within-window movement, window scrolling, and wrap-around behavior
     * 
     * Navigation priority:
     * 1. Move down within visible window (fastest)
     * 2. Scroll window down to show later snippets
     * 3. Wrap to top of list (infinite scrolling)
     * 
     * Side effects:
     * - Updates navigation state (currentIndex and/or visibleRangeStartIndex)
     * - Logs comprehensive debug information
     * - Emits selectionChanged signal
     */
    function moveDown() {
        if (snippets.length === 0) {
            debugLog("❌ Navigation ignored - no snippets available")
            return
        }
        
        if (canMoveDownWithinWindow()) {
            moveDownWithinWindow()
        } else if (canScrollWindowDown()) {
            scrollWindowDown()
        } else {
            wrapToTop()
        }
        
        updateNavigationState("DOWN")
        selectionChanged()
    }
    
    // ============================================================================
    // STATE MANAGEMENT
    // ============================================================================
    
    /**
     * Logs comprehensive navigation state information for debugging
     * Called after every navigation action to provide visibility into window position
     * 
     * @param {string} direction - Navigation direction ("UP" or "DOWN")
     * 
     * Side effects:
     * - Logs debug message with current global position, window range, and total count
     * - Only logs if debug mode is enabled
     */
    function updateNavigationState(direction) {
        debugLog(`🔵 Navigation ${direction}: Global ${globalIndex}, Window ${visibleRangeStartIndex}-${visibleRangeStartIndex + maxDisplayed - 1}, Total: ${snippets.length}`)
    }
    
    /**
     * Resets navigation state to initial position
     * Used when snippet data changes or controller is reinitialized
     * 
     * Side effects:
     * - Sets visibleRangeStartIndex to 0
     * - Sets currentIndex to 0
     * - Logs debug message
     * - Emits selectionChanged signal
     */
    function reset() {
        visibleRangeStartIndex = 0
        currentIndex = 0
        debugLog(`🔄 Navigation reset to initial state`)
        selectionChanged()
    }
    
    // ============================================================================
    // LIFECYCLE
    // ============================================================================
    
    Component.onCompleted: {
        debugLog(`🎯 NavigationController initialized with ${snippets.length} snippets, maxDisplayed: ${maxDisplayed}`)
    }
    
    // Auto-reset when snippets change
    onSnippetsChanged: {
        if (snippets.length === 0) {
            reset()
        } else {
            // Ensure current position is still valid
            if (globalIndex >= snippets.length) {
                reset()
            }
        }
    }
}