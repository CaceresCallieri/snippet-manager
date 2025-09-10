import QtQuick
import "../utils"

/**
 * Simplified Navigation Controller for Snippet Manager
 * 
 * Provides sliding window navigation with straightforward array index management.
 * Implements VS Code-style navigation where a fixed number of items are displayed
 * while users can navigate through the full collection with smooth scrolling.
 * 
 * Simplified from 384 lines to focus on core functionality:
 * - Direct array index calculations instead of 16+ helper functions
 * - Inline bounds checking instead of complex predicate functions
 * - Clear, readable navigation logic without excessive abstraction
 * 
 * Features:
 * - Sliding window navigation (displays subset, navigates full collection)
 * - Wrap-around navigation (infinite scrolling feel)
 * - Comprehensive bounds checking and edge case handling
 * - Maintains full API compatibility with OverlayWindow
 * 
 * Usage:
 * ```qml
 * NavigationController {
 *     id: navController
 *     snippets: mySnippetsArray
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
     */
    property int maxDisplayed: Constants.maxVisibleSnippets
    
    /**
     * Debug logging function passed from parent component
     */
    property var debugLog: null
    
    // ============================================================================
    // COMPUTED PROPERTIES
    // ============================================================================
    
    /**
     * Absolute position in the full snippets array
     * @returns {int} Global index (0-based position across all snippets)
     */
    readonly property int globalIndex: visibleRangeStartIndex + currentIndex
    
    /**
     * Currently visible subset of snippets for UI display
     * Uses sliding window approach to show maxDisplayed items from full array
     * 
     * @returns {Array} Subset of snippets array (max maxDisplayed items) for UI display
     */
    readonly property var visibleSnippetWindow: {
        if (snippets.length === 0) return []
        const endIndex = Math.min(visibleRangeStartIndex + maxDisplayed, snippets.length)
        return snippets.slice(visibleRangeStartIndex, endIndex)
    }
    
    // ============================================================================
    // SIGNALS
    // ============================================================================
    
    /**
     * Emitted when navigation state changes (selection moves)
     * Connected components can listen to this signal to update their UI
     */
    signal selectionChanged()
    
    // ============================================================================
    // PUBLIC METHODS
    // ============================================================================
    
    /**
     * Move selection up with wrap-around and sliding window support
     * 
     * Navigation logic:
     * 1. If at absolute top: wrap to bottom of list
     * 2. If at top of visible window: scroll window up
     * 3. Otherwise: move cursor up within window
     */
    function moveUp() {
        if (snippets.length === 0) {
            debugLog("❌ Navigation ignored - no snippets available")
            return
        }
        
        const atAbsoluteTop = (visibleRangeStartIndex === 0 && currentIndex === 0)
        if (atAbsoluteTop) {
            // Wrap to bottom: position window and cursor at end of list
            visibleRangeStartIndex = Math.max(0, snippets.length - maxDisplayed)
            currentIndex = Math.min(maxDisplayed - 1, snippets.length - 1 - visibleRangeStartIndex)
            debugLog(`🔄 Wrapped to bottom: window ${visibleRangeStartIndex}-${visibleRangeStartIndex + maxDisplayed - 1}, cursor ${currentIndex}`)
        } else if (currentIndex === 0) {
            // Scroll window up (cursor stays at top of visible window)
            visibleRangeStartIndex = Math.max(0, visibleRangeStartIndex - 1)
            debugLog(`⬆️ Scrolled window up to ${visibleRangeStartIndex}`)
        } else {
            // Move cursor up within visible window
            currentIndex--
            debugLog(`🎯 Moved up within window to index ${currentIndex}`)
        }
        
        debugLog(`🔵 Navigation UP: Global ${globalIndex}, Window ${visibleRangeStartIndex}-${visibleRangeStartIndex + maxDisplayed - 1}, Total: ${snippets.length}`)
        selectionChanged()
    }
    
    /**
     * Move selection down with wrap-around and sliding window support
     * 
     * Navigation logic:
     * 1. If at absolute bottom: wrap to top of list
     * 2. If at bottom of visible window and can scroll: scroll window down
     * 3. Otherwise: move cursor down within window
     */
    function moveDown() {
        if (snippets.length === 0) {
            debugLog("❌ Navigation ignored - no snippets available")
            return
        }
        
        const atAbsoluteBottom = (globalIndex === snippets.length - 1)
        if (atAbsoluteBottom) {
            // Wrap to top: reset both window and cursor
            visibleRangeStartIndex = 0
            currentIndex = 0
            debugLog(`🔄 Wrapped to top: window 0-${maxDisplayed - 1}, cursor 0`)
        } else {
            const atVisibleBottom = (currentIndex === visibleSnippetWindow.length - 1)
            const canScrollWindow = (visibleRangeStartIndex + maxDisplayed < snippets.length)
            
            if (atVisibleBottom && canScrollWindow) {
                // Scroll window down (cursor stays at bottom of visible window)
                visibleRangeStartIndex++
                debugLog(`⬇️ Scrolled window down to ${visibleRangeStartIndex}`)
            } else if (currentIndex < visibleSnippetWindow.length - 1) {
                // Move cursor down within visible window
                currentIndex++
                debugLog(`🎯 Moved down within window to index ${currentIndex}`)
            }
        }
        
        debugLog(`🔵 Navigation DOWN: Global ${globalIndex}, Window ${visibleRangeStartIndex}-${visibleRangeStartIndex + maxDisplayed - 1}, Total: ${snippets.length}`)
        selectionChanged()
    }
    
    /**
     * Reset navigation to initial state
     * Called when snippet array changes or component initializes
     */
    function reset() {
        visibleRangeStartIndex = 0
        currentIndex = 0
        debugLog("🔄 Navigation reset to initial state")
        selectionChanged()
    }
    
    // ============================================================================
    // PRIVATE METHODS
    // ============================================================================
    
    
    // ============================================================================
    // EVENT HANDLERS
    // ============================================================================
    
    /**
     * Reset navigation when snippets array changes
     * Ensures navigation state remains valid when data is updated
     */
    onSnippetsChanged: {
        reset()
        debugLog(`🎯 NavigationController initialized with ${snippets.length} snippets, maxDisplayed: ${maxDisplayed}`)
    }
}