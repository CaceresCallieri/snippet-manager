pragma Singleton
import QtQuick
import "../utils"

/**
 * Unified Validation Utility Singleton
 * 
 * Centralizes all snippet validation logic to eliminate code duplication across
 * shell.qml, CombiningModeController.qml, SnippetCombiner.qml, and OverlayWindow.qml.
 * 
 * Provides comprehensive validation functions for:
 * - Individual snippet objects (structure, properties, types, size limits)
 * - Snippet arrays and collections
 * - Combined text size validation
 * - Quick data validation before text injection
 * 
 * All validation functions maintain existing logging behavior and error messages
 * for backward compatibility with current error handling patterns.
 * 
 * Usage:
 * ```qml
 * import "../utils"
 * 
 * if (Validation.isValidSnippet(snippet)) {
 *     // Process valid snippet
 * }
 * ```
 */
QtObject {
    id: validation
    
    // ============================================================================
    // VALIDATION CONSTANTS
    // ============================================================================
    
    /**
     * Maximum allowed title length (consistent with Constants.validation)
     */
    readonly property int maxTitleLength: Constants.validation.maxTitleLength
    
    /**
     * Maximum allowed content length (consistent with Constants.validation and inject-text.sh)
     */
    readonly property int maxContentLength: Constants.validation.maxContentLength
    
    // ============================================================================
    // PRIMARY VALIDATION FUNCTIONS
    // ============================================================================
    
    /**
     * Comprehensive snippet validation with size limits and detailed logging
     * Replaces shell.qml validateSnippet() function
     * 
     * @param {Object} snippet - Snippet object to validate
     * @param {number} index - Array index for error reporting (optional)
     * @returns {boolean} True if snippet passes all validation levels
     * 
     * Validation levels:
     * 1. Object structure - existence and type checking
     * 2. Required fields - title and content properties must exist
     * 3. Type validation - both properties must be strings  
     * 4. Content limits - title ≤ 200 chars, content ≤ 10KB
     */
    function isValidSnippet(snippet, index) {
        const indexStr = index !== undefined ? index : "unknown"
        
        // Level 1: Object structure validation
        if (!snippet || typeof snippet !== 'object') {
            console.warn(`Snippet ${indexStr}: Invalid object (${typeof snippet})`)
            return false
        }
        
        // Level 2: Required field validation
        if (!snippet.hasOwnProperty('title')) {
            console.warn(`Snippet ${indexStr}: Missing title property`)
            return false
        }
        
        if (!snippet.hasOwnProperty('content')) {
            console.warn(`Snippet ${indexStr}: Missing content property`)
            return false
        }
        
        // Level 3: Type validation
        if (typeof snippet.title !== 'string') {
            console.warn(`Snippet ${indexStr}: Title must be string, got ${typeof snippet.title}`)
            return false
        }
        
        if (typeof snippet.content !== 'string') {
            console.warn(`Snippet ${indexStr}: Content must be string, got ${typeof snippet.content}`)
            return false
        }
        
        // Level 4: Content limits (consistent with inject-text.sh)
        if (snippet.title.length > maxTitleLength) {
            console.warn(`Snippet ${indexStr}: Title too long (${snippet.title.length} chars, max ${maxTitleLength})`)
            return false
        }
        
        if (snippet.content.length > maxContentLength) {
            console.warn(`Snippet ${indexStr}: Content too long (${snippet.content.length} chars, max ${maxContentLength})`)
            return false
        }
        
        return true
    }
    
    /**
     * Fast validation for snippet structure without size limits or logging
     * Replaces shell.qml validateSnippetData() and similar functions
     * 
     * @param {Object} snippet - Snippet object to validate
     * @returns {boolean} True if snippet has valid structure and properties
     * 
     * Used for final safety checks before text injection where detailed logging
     * is not needed and size limits are already enforced by previous validation.
     */
    function isValidSnippetStructure(snippet) {
        return snippet && 
               typeof snippet === 'object' &&
               snippet.hasOwnProperty('title') && 
               snippet.hasOwnProperty('content') &&
               typeof snippet.title === 'string' &&
               typeof snippet.content === 'string'
    }
    
    // ============================================================================
    // COLLECTION VALIDATION FUNCTIONS
    // ============================================================================
    
    /**
     * Validates that input is a valid non-empty array
     * Replaces SnippetCombiner.qml validateSnippetArray() function
     * 
     * @param {any} snippets - Input to validate
     * @returns {boolean} True if valid snippet array
     */
    function isValidSnippetArray(snippets) {
        if (!snippets || !Array.isArray(snippets)) {
            console.error("❌ Validation: snippets must be an array")
            return false
        }
        
        if (snippets.length === 0) {
            console.error("❌ Validation: cannot process empty snippet array")
            return false
        }
        
        return true
    }
    
    /**
     * Validates combined text size is within security limits
     * Replaces SnippetCombiner.qml validateCombinedSize() function
     * 
     * @param {number} size - Total character count
     * @returns {boolean} True if size is within acceptable limits
     */
    function isValidCombinedSize(size) {
        return size > 0 && size <= maxContentLength
    }
    
    /**
     * Validates final combined text meets all requirements
     * Replaces SnippetCombiner.qml validateFinalText() function
     * 
     * @param {string} text - Combined text to validate
     * @returns {boolean} True if text passes final validation
     */
    function isValidFinalText(text) {
        if (!text || typeof text !== 'string') {
            return false
        }
        
        if (text.length === 0) {
            return false
        }
        
        if (text.length > maxContentLength) {
            return false
        }
        
        return true
    }
    
    // ============================================================================
    // SPECIALIZED VALIDATION FUNCTIONS
    // ============================================================================
    
    /**
     * Comprehensive validation for snippet addition with error signaling
     * Replaces CombiningModeController.qml validateSnippetForAddition() logic
     * 
     * @param {Object} snippet - Snippet object to validate
     * @param {function} errorCallback - Function to call on validation failure (error, type)
     * @returns {boolean} True if snippet is valid for addition
     * 
     * This function provides the same validation as isValidSnippetStructure but
     * with detailed error reporting for UI feedback purposes.
     */
    function validateSnippetForAddition(snippet, errorCallback) {
        if (!snippet) {
            const error = "Cannot add null snippet to combination"
            if (errorCallback) errorCallback(error, "invalid_data")
            return false
        }
        
        if (typeof snippet !== 'object') {
            const error = `Invalid snippet type: expected object, got ${typeof snippet}`
            if (errorCallback) errorCallback(error, "invalid_data")
            return false
        }
        
        if (!snippet.hasOwnProperty('title') || typeof snippet.title !== 'string') {
            const error = "Snippet missing valid title property"
            if (errorCallback) errorCallback(error, "invalid_data")
            return false
        }
        
        if (!snippet.hasOwnProperty('content') || typeof snippet.content !== 'string') {
            const error = "Snippet missing valid content property"
            if (errorCallback) errorCallback(error, "invalid_data")
            return false
        }
        
        return true
    }
}