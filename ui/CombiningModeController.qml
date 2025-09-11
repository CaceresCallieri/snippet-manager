import QtQuick
import "../utils"

/**
 * CombiningModeController - State management component for snippet combination mode
 * 
 * Manages the combining mode state, selected snippets array, and coordination between
 * user interactions and the combination system. Provides a clean API for the main UI
 * to interact with combination functionality without managing complex state directly.
 * 
 * Key Responsibilities:
 * - Combining mode state management (enter/exit mode)
 * - Selected snippets collection and validation
 * - Size tracking and limit enforcement
 * - Duplicate detection and prevention
 * - Integration with SnippetCombiner for final processing
 * 
 * Usage:
 * CombiningModeController { id: combiningController }
 */
Item {
    id: controller
    
    // ============================================================================
    // PUBLIC PROPERTIES
    // ============================================================================
    
    /**
     * Whether combining mode is currently active
     * When true, SPACE adds snippets and ENTER triggers combination
     * When false, normal single-snippet selection behavior
     * 
     * @type {boolean}
     */
    property bool isCombiningMode: false
    
    /**
     * Array of snippets selected for combination
     * Each entry is a complete snippet object with title and content
     * Automatically maintained with duplicate prevention
     * 
     * @type {Array<Object>}
     */
    property var combinedSnippets: []
    
    /**
     * Total character count of all selected snippet content
     * Updated automatically when snippets are added or removed
     * Used for size validation and user feedback
     * 
     * @type {number}
     */
    property int combinedCharacterCount: 0
    
    /**
     * Whether the size limit would be exceeded by adding another snippet
     * Computed property for UI feedback and validation
     * 
     * @type {boolean}
     */
    readonly property bool isNearSizeLimit: combinedCharacterCount > 8000
    
    /**
     * User-friendly status message describing current combination state
     * Used for header display and user feedback
     * 
     * @type {string}
     */
    readonly property string statusMessage: {
        if (!isCombiningMode) {
            return ""
        }
        
        if (combinedSnippets.length === 0) {
            return "Combining Mode - Select snippets with SPACE"
        }
        
        const count = combinedSnippets.length
        const charCount = combinedCharacterCount
        const maxChars = 10000
        
        return `Combining Mode (${count} selected, ${charCount}/${maxChars} chars)`
    }
    
    // ============================================================================
    // SIGNALS
    // ============================================================================
    
    /**
     * Emitted when combining mode state changes
     * @param {boolean} isActive - New combining mode state
     */
    signal modeChanged(bool isActive)
    
    /**
     * Emitted when snippets are successfully combined and ready for injection
     * @param {Object} combinedSnippet - Combined snippet object with title/content
     */
    signal snippetReady(var combinedSnippet)
    
    /**
     * Emitted when snippet addition fails due to validation errors
     * @param {string} error - Description of the failure
     * @param {string} errorType - Category of error
     */
    signal additionFailed(string error, string errorType)
    
    /**
     * Emitted when combination fails due to processing errors
     * @param {string} error - Description of the failure
     * @param {string} errorType - Category of error
     */
    signal combinationFailed(string error, string errorType)
    
    // ============================================================================
    // INTERNAL COMPONENTS
    // ============================================================================
    
    /**
     * Core combination logic component
     * Handles text processing, validation, and final combination
     */
    SnippetCombiner {
        id: combiner
        
        onCombinationReady: function(combinedText) {
            // Create a synthetic snippet object for the combined result
            const combinedSnippet = {
                title: `Combined Snippet (${controller.combinedSnippets.length} parts)`,
                content: combinedText
            }
            
            controller.debugLog(`✅ Combination ready: ${combinedText.length} characters`)
            controller.snippetReady(combinedSnippet)
        }
        
        onCombinationFailed: function(error, errorType) {
            console.error(`❌ Combination failed: ${error} (${errorType})`)
            controller.combinationFailed(error, errorType)
        }
    }
    
    // ============================================================================
    // DEBUG LOGGING
    // ============================================================================
    
    /**
     * Debug logging function (will be injected by parent)
     * @param {string} message - Debug message to log
     */
    property var debugLog: function(message) {
        console.log(message)
    }
    
    // ============================================================================
    // PUBLIC API
    // ============================================================================
    
    /**
     * Adds a snippet to the combination collection
     * Performs validation, duplicate checking, and size limit enforcement
     * 
     * @param {Object} snippet - Snippet object to add to combination
     * @returns {boolean} True if snippet was successfully added
     * 
     * Validation steps:
     * 1. Snippet object validation (structure, required properties)
     * 2. Duplicate detection (prevents adding same snippet twice)  
     * 3. Size limit checking (ensures combined size stays within limits)
     * 4. Collection update and character count recalculation
     * 
     * Side effects:
     * - Updates combinedSnippets array and combinedCharacterCount
     * - Enters combining mode if not already active
     * - Emits additionFailed signal on validation failures
     * - Logs detailed operation results for debugging
     */
    function addSnippet(snippet) {
        if (!Validation.validateSnippetForAddition(snippet, function(error, type) {
            debugLog(`❌ ${error}`)
            additionFailed(error, type)
        })) {
            return false
        }
        
        if (combiner.isDuplicateSnippet(combinedSnippets, snippet)) {
            const error = `Snippet "${snippet.title}" is already in combination`
            debugLog(`⚠️ ${error}`)
            additionFailed(error, "duplicate")
            return false
        }
        
        if (!combiner.canAddSnippet(combinedSnippets, snippet)) {
            const currentSize = combiner.calculateCombinedSize(combinedSnippets)
            const newSize = currentSize + snippet.content.length
            const error = `Adding snippet would exceed size limit: ${newSize} > 10000`
            debugLog(`⚠️ ${error}`)
            additionFailed(error, "size_limit")
            return false
        }
        
        // Add snippet and update state
        var newArray = combinedSnippets.slice() // Create copy to trigger property change
        newArray.push(snippet)
        combinedSnippets = newArray
        
        updateCharacterCount()
        
        // Enter combining mode if not already active
        if (!isCombiningMode) {
            enterCombiningMode()
        }
        
        debugLog(`✅ Added snippet to combination: "${snippet.title}" (${snippet.content.length} chars)`)
        debugLog(`📊 Combination status: ${combinedSnippets.length} snippets, ${combinedCharacterCount} total chars`)
        
        return true
    }
    
    /**
     * Processes the current combination and prepares final snippet for injection
     * Validates the combination, processes it through SnippetCombiner, and emits result
     * 
     * @returns {boolean} True if combination was successfully processed
     * 
     * Processing flow:
     * 1. Validates that snippets are available for combination
     * 2. Delegates to SnippetCombiner for text processing and validation
     * 3. SnippetCombiner emits combinationReady or combinationFailed signals
     * 4. Controller forwards results to parent UI components
     * 
     * Side effects:
     * - Triggers SnippetCombiner processing
     * - May emit snippetReady or combinationFailed signals via combiner
     * - Logs combination attempt and status information
     */
    function executeCombination() {
        if (combinedSnippets.length === 0) {
            const error = "No snippets selected for combination"
            debugLog(`❌ ${error}`)
            combinationFailed(error, "empty_combination")
            return false
        }
        
        debugLog(`🔄 Executing combination of ${combinedSnippets.length} snippets...`)
        
        // Delegate to SnippetCombiner for processing
        const result = combiner.combineSnippets(combinedSnippets)
        
        // Result handling is done via combiner signals (onCombinationReady/onCombinationFailed)
        return result.length > 0
    }
    
    /**
     * Clears all selected snippets from combination without exiting combining mode
     * Useful for starting a new combination while staying in combining mode
     * 
     * Side effects:
     * - Clears combinedSnippets array and resets combinedCharacterCount to 0
     * - Maintains isCombiningMode state (user must explicitly exit mode)
     * - Logs clearing operation for debugging
     */
    function clearCombination() {
        const previousCount = combinedSnippets.length
        combinedSnippets = []
        combinedCharacterCount = 0
        
        debugLog(`🧹 Cleared combination (${previousCount} snippets removed)`)
    }
    
    /**
     * Enters combining mode and initializes state
     * Sets up the UI for snippet collection workflow
     * 
     * Side effects:
     * - Sets isCombiningMode to true
     * - Emits modeChanged signal for UI updates
     * - Logs mode transition for debugging
     */
    function enterCombiningMode() {
        if (!isCombiningMode) {
            isCombiningMode = true
            debugLog("🔄 Entered combining mode")
            modeChanged(true)
        }
    }
    
    /**
     * Exits combining mode and clears all state
     * Returns to normal single-snippet selection behavior
     * 
     * Side effects:
     * - Sets isCombiningMode to false
     * - Clears all selected snippets and resets character count
     * - Emits modeChanged signal for UI updates
     * - Logs mode transition and cleanup for debugging
     */
    function exitCombiningMode() {
        if (isCombiningMode) {
            const previousCount = combinedSnippets.length
            
            isCombiningMode = false
            clearCombination()
            
            debugLog(`🔴 Exited combining mode (cleared ${previousCount} snippets)`)
            modeChanged(false)
        }
    }
    
    /**
     * Removes a specific snippet from the combination by index
     * Useful for UI interfaces that allow removing individual snippets
     * 
     * @param {number} index - Index of snippet to remove from combinedSnippets array
     * @returns {boolean} True if snippet was successfully removed
     * 
     * Side effects:
     * - Updates combinedSnippets array and recalculates character count
     * - Logs removal operation with snippet details
     * - Exits combining mode if no snippets remain after removal
     */
    function removeSnippetAt(index) {
        if (index < 0 || index >= combinedSnippets.length) {
            debugLog(`❌ Invalid index for snippet removal: ${index}`)
            return false
        }
        
        const removedSnippet = combinedSnippets[index]
        var newArray = combinedSnippets.slice()
        newArray.splice(index, 1)
        combinedSnippets = newArray
        
        updateCharacterCount()
        
        debugLog(`🗑️ Removed snippet at index ${index}: "${removedSnippet.title}"`)
        
        // Exit combining mode if no snippets remain
        if (combinedSnippets.length === 0) {
            exitCombiningMode()
        }
        
        return true
    }
    
    // ============================================================================
    // PRIVATE HELPERS
    // ============================================================================
    
    
    /**
     * Recalculates and updates the combined character count
     * Called whenever combinedSnippets array changes
     */
    function updateCharacterCount() {
        combinedCharacterCount = combiner.calculateCombinedSize(combinedSnippets)
    }
    
    // ============================================================================
    // REACTIVE UPDATES
    // ============================================================================
    
    /**
     * Monitor changes to combinedSnippets array and update character count
     * Ensures character count stays synchronized with snippet collection
     */
    onCombinedSnippetsChanged: {
        updateCharacterCount()
    }
}