import QtQuick
import "../utils"

/**
 * SnippetCombiner - Pure business logic component for snippet combination operations
 * 
 * Provides core functionality for combining multiple snippets into a single text block
 * with proper validation, formatting, and size checking. This component contains no UI
 * dependencies and focuses purely on text processing and validation logic.
 * 
 * Key Features:
 * - Text combination with newline separation
 * - Size validation against security limits  
 * - Duplicate detection and prevention
 * - Content validation and sanitization
 * 
 * Usage:
 * ```qml
 * SnippetCombiner {
 *     id: combiner
 *     onCombinationReady: function(combinedText) {
 *         // Handle the combined result
 *     }
 * }
 * ```
 */
QtObject {
    id: combiner
    
    // ============================================================================
    // SIGNALS
    // ============================================================================
    
    /**
     * Emitted when snippets have been successfully combined and are ready for use
     * @param {string} combinedText - The final combined text ready for injection
     */
    signal combinationReady(string combinedText)
    
    /**
     * Emitted when combination fails due to validation errors
     * @param {string} error - Description of the validation failure
     * @param {string} errorType - Category of error ("size_limit", "invalid_data", etc.)
     */
    signal combinationFailed(string error, string errorType)
    
    // ============================================================================
    // PUBLIC API
    // ============================================================================
    
    /**
     * Combines an array of snippets into a single text block with newline separation
     * Performs comprehensive validation before and after combination process.
     * 
     * @param {Array<Object>} snippets - Array of snippet objects with title/content properties
     * @returns {string} Combined text ready for injection, or empty string on failure
     * 
     * Processing steps:
     * 1. Input validation - ensures valid snippet array and objects
     * 2. Content extraction - extracts content from each snippet 
     * 3. Size validation - checks combined size against limits
     * 4. Text formatting - joins content with newlines
     * 5. Final validation - ensures result meets all requirements
     * 
     * Side effects:
     * - Emits combinationReady signal on success
     * - Emits combinationFailed signal on validation failures
     * - Logs detailed processing information for debugging
     */
    function combineSnippets(snippets) {
        if (!validateSnippetArray(snippets)) {
            const error = "Invalid snippet array provided for combination"
            combinationFailed(error, "invalid_data")
            return ""
        }
        
        // Extract content from all snippets
        var contentArray = []
        var totalSize = 0
        
        for (var i = 0; i < snippets.length; i++) {
            const snippet = snippets[i]
            
            if (!Validation.isValidSnippetStructure(snippet)) {
                const error = `Invalid snippet at index ${i}: missing required properties`
                combinationFailed(error, "invalid_data")
                return ""
            }
            
            contentArray.push(snippet.content)
            totalSize += snippet.content.length
        }
        
        // Validate combined size before creating final text
        if (!Validation.isValidCombinedSize(totalSize)) {
            const error = `Combined content exceeds size limit: ${totalSize} > ${Validation.maxContentLength} characters`
            combinationFailed(error, "size_limit")
            return ""
        }
        
        // Create final combined text with newline separation
        const combinedText = contentArray.join('\n')
        
        // Final validation of combined result
        if (!Validation.isValidFinalText(combinedText)) {
            const error = "Combined text failed final validation checks"
            combinationFailed(error, "validation_failure")
            return ""
        }
        
        console.log(`✅ Successfully combined ${snippets.length} snippets (${combinedText.length} chars)`)
        combinationReady(combinedText)
        return combinedText
    }
    
    /**
     * Calculates the total character count for an array of snippets
     * Used for preview and validation before actual combination.
     * 
     * @param {Array<Object>} snippets - Array of snippet objects
     * @returns {number} Total character count of all snippet content
     * 
     * Side effects:
     * - No side effects - pure calculation function
     * - Safe for use in property bindings and reactive contexts
     */
    function calculateCombinedSize(snippets) {
        if (!snippets || !Array.isArray(snippets)) {
            return 0
        }
        
        var totalSize = 0
        for (var i = 0; i < snippets.length; i++) {
            const snippet = snippets[i]
            if (snippet && snippet.content && typeof snippet.content === 'string') {
                totalSize += snippet.content.length
            }
        }
        
        return totalSize
    }
    
    /**
     * Checks if adding a new snippet would exceed size limits
     * Used for preventive validation when user selects snippets for combination.
     * 
     * @param {Array<Object>} existingSnippets - Currently selected snippets
     * @param {Object} newSnippet - Snippet to potentially add
     * @returns {boolean} True if addition is safe, false if it would exceed limits
     * 
     * Side effects:
     * - No side effects - pure validation function
     * - Safe for use in UI validation contexts
     */
    function canAddSnippet(existingSnippets, newSnippet) {
        if (!newSnippet || !newSnippet.content || typeof newSnippet.content !== 'string') {
            return false
        }
        
        const currentSize = calculateCombinedSize(existingSnippets)
        const newSize = currentSize + newSnippet.content.length
        
        return newSize <= 10000
    }
    
    /**
     * Detects if a snippet is already present in the combination array
     * Prevents duplicate snippets from being added to combination.
     * 
     * @param {Array<Object>} snippets - Array of currently selected snippets
     * @param {Object} targetSnippet - Snippet to check for duplication
     * @returns {boolean} True if snippet is already in the array
     * 
     * Comparison logic:
     * - Compares both title and content for exact matches
     * - Case-sensitive comparison for accuracy
     * - Handles edge cases (null/undefined values)
     * 
     * Side effects:
     * - No side effects - pure comparison function
     * - Safe for use in reactive validation contexts
     */
    function isDuplicateSnippet(snippets, targetSnippet) {
        if (!snippets || !Array.isArray(snippets) || !targetSnippet) {
            return false
        }
        
        for (var i = 0; i < snippets.length; i++) {
            const existing = snippets[i]
            if (existing && 
                existing.title === targetSnippet.title && 
                existing.content === targetSnippet.content) {
                return true
            }
        }
        
        return false
    }
    
    // ============================================================================
    // PRIVATE VALIDATION HELPERS
    // ============================================================================
    
    /**
     * Validates that input is a valid array of snippets
     * @param {any} snippets - Input to validate
     * @returns {boolean} True if valid snippet array
     */
    function validateSnippetArray(snippets) {
        if (!snippets || !Array.isArray(snippets)) {
            console.error("❌ Combiner: snippets must be an array")
            return false
        }
        
        if (snippets.length === 0) {
            console.error("❌ Combiner: cannot combine empty snippet array")
            return false
        }
        
        return true
    }
    
    /**
     * Validates that a snippet object has required properties
     * @param {Object} snippet - Snippet object to validate
     * @returns {boolean} True if snippet has valid structure
     */
    function validateSnippetObject(snippet) {
        if (!snippet || typeof snippet !== 'object') {
            return false
        }
        
        if (!snippet.hasOwnProperty('title') || typeof snippet.title !== 'string') {
            return false
        }
        
        if (!snippet.hasOwnProperty('content') || typeof snippet.content !== 'string') {
            return false
        }
        
        return true
    }
    
    
}