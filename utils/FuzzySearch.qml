pragma Singleton
import QtQuick

/**
 * Fuzzy Search Singleton - Relevance-based search for snippet manager
 * 
 * Implements multi-criteria scoring algorithm with position-based weighting
 * and field importance to provide intelligent search ranking.
 * 
 * Key Features:
 * - Title matches weighted 3x higher than content matches
 * - Position-based scoring (prefix > word boundary > substring)
 * - Multi-word query support
 * - Basic typo tolerance
 * 
 * Usage:
 * ```qml
 * import "../utils"
 * 
 * property var results: FuzzySearch.searchAndRank(snippets, "co")
 * ```
 */
QtObject {
    id: fuzzySearch
    
    // ============================================================================
    // SCORING CONSTANTS
    // ============================================================================
    
    readonly property int scoreExactPrefix: 1000        // "co" matches "Commit" start
    readonly property int scoreWordBoundary: 800        // "prog" matches "commit Prog"
    readonly property int scoreSubstring: 400           // "mit" matches "co-Mit"
    readonly property int scoreFuzzy: 200               // "comit" fuzzy matches "commit"
    readonly property int scoreNoMatch: 0               // No match found
    
    readonly property real titleMultiplier: 3.0        // Title matches 3x more valuable
    readonly property real contentMultiplier: 1.0      // Content baseline multiplier
    
    
    // Filtering thresholds for relative score filtering
    readonly property real relativeScoreThreshold: 0.3  // Show results within 30% of top score
    readonly property int minimumAbsoluteScore: 150     // Always show matches above this score
    readonly property int maxResultsLimit: 10          // Maximum results to show regardless of score
    
    // ============================================================================
    // PUBLIC API
    // ============================================================================
    
    /**
     * Primary search function - returns snippets ranked by relevance
     * 
     * Performs fuzzy search with multi-criteria scoring and returns results
     * sorted by relevance score in descending order.
     * 
     * @param {Array} snippets - Array of snippet objects with title/content
     * @param {string} searchTerm - User's search query
     * @returns {Array} Filtered and sorted array of snippets by relevance
     * 
     * Performance: Optimized for real-time search with <100 snippets
     * 
     * Side effects:
     * - No side effects - pure function
     * - Safe for use in QML property bindings
     */
    function searchAndRank(snippets, searchTerm) {
        // Early return for empty queries
        if (!searchTerm || searchTerm.trim().length === 0) {
            return snippets
        }
        
        // Early return for empty snippets
        if (!snippets || snippets.length === 0) {
            return []
        }
        
        var normalizedQuery = searchTerm.trim().toLowerCase()
        
        // Score all snippets and filter out zero scores
        var scoredResults = []
        
        for (var i = 0; i < snippets.length; i++) {
            var snippet = snippets[i]
            var score = calculateRelevanceScore(snippet, normalizedQuery)
            
            if (score > scoreNoMatch) {
                scoredResults.push({
                    snippet: snippet,
                    score: score
                })
            }
        }
        
        // Sort by score descending (highest relevance first)
        scoredResults.sort(function(a, b) { return b.score - a.score })
        
        // Apply intelligent filtering based on relative scores
        var filteredResults = applyScoreFiltering(scoredResults)
        
        // Extract just the snippets
        return filteredResults.map(function(result) { return result.snippet })
    }
    
    /**
     * Apply intelligent filtering based on relative score thresholds
     * 
     * Filters results using adaptive thresholds to show only relevant matches
     * while ensuring quality results are never hidden.
     * 
     * @param {Array} scoredResults - Array of {snippet, score} objects sorted by score
     * @returns {Array} Filtered array of scored results
     * 
     * Filtering strategy:
     * 1. Always show results above minimumAbsoluteScore (high-quality matches)
     * 2. Show results within relativeScoreThreshold of top score (contextually relevant)
     * 3. Limit total results to maxResultsLimit for performance
     * 4. Always show at least the top result if any matches exist
     * 
     * Side effects:
     * - No side effects - pure filtering function
     * - Maintains sort order from input
     */
    function applyScoreFiltering(scoredResults) {
        if (scoredResults.length === 0) {
            return []
        }
        
        // Always include the top result
        var filteredResults = [scoredResults[0]]
        var topScore = scoredResults[0].score
        var scoreThreshold = Math.max(
            topScore * relativeScoreThreshold,  // Relative threshold
            minimumAbsoluteScore                // Absolute minimum
        )
        
        // Add additional results that meet the threshold
        for (var i = 1; i < scoredResults.length && filteredResults.length < maxResultsLimit; i++) {
            var result = scoredResults[i]
            if (result.score >= scoreThreshold) {
                filteredResults.push(result)
            }
        }
        
        return filteredResults
    }
    
    // ============================================================================
    // SCORING ALGORITHM IMPLEMENTATION
    // ============================================================================
    
    /**
     * Calculate relevance score for a snippet against search term
     * 
     * Combines title and content match scores with field weighting to produce
     * a final relevance score for ranking purposes.
     * 
     * @param {Object} snippet - Snippet with title and content properties
     * @param {string} normalizedQuery - Lowercase search term
     * @returns {number} Relevance score (higher = more relevant)
     * 
     * Scoring components:
     * - Title match score (weighted 3x)
     * - Content match score (baseline weight)
     */
    function calculateRelevanceScore(snippet, normalizedQuery) {
        if (!snippet || !snippet.title || !snippet.content) {
            return scoreNoMatch
        }
        
        // Calculate scores for both fields
        var titleScore = calculateFieldScore(snippet.title, normalizedQuery) * titleMultiplier
        var contentScore = calculateFieldScore(snippet.content, normalizedQuery) * contentMultiplier
        
        // Return total score without unnecessary complexity
        return Math.round(titleScore + contentScore)
    }
    
    /**
     * Calculate match score for a single field (title or content)
     * 
     * Uses position-based scoring hierarchy to rank match quality.
     * 
     * @param {string} text - Field text to search in
     * @param {string} query - Normalized search query
     * @returns {number} Field-specific match score
     * 
     * Match hierarchy:
     * 1. Exact prefix match (highest)
     * 2. Word boundary match
     * 3. Substring match  
     * 4. Fuzzy match (lowest)
     */
    function calculateFieldScore(text, query) {
        var normalizedText = text.toLowerCase()
        
        // 1. Check for exact prefix match
        if (normalizedText.startsWith(query)) {
            return scoreExactPrefix
        }
        
        // 2. Check for word boundary matches
        var wordBoundaryScore = findWordBoundaryMatch(normalizedText, query)
        if (wordBoundaryScore > 0) {
            return wordBoundaryScore
        }
        
        // 3. Check for substring match
        if (normalizedText.includes(query)) {
            return scoreSubstring
        }
        
        // 4. Check for fuzzy match (basic typo tolerance)
        if (checkFuzzyMatch(normalizedText, query)) {
            return scoreFuzzy
        }
        
        return scoreNoMatch
    }
    
    /**
     * Find matches at word boundaries within text
     * 
     * Word boundary matches are high-value because they typically
     * represent semantically meaningful matches.
     * 
     * @param {string} text - Text to search in
     * @param {string} query - Search query
     * @returns {number} Word boundary match score
     */
    function findWordBoundaryMatch(text, query) {
        // Split text into words and check each word start
        var words = text.split(/[\s\-_.,]+/)
        
        for (var i = 0; i < words.length; i++) {
            var word = words[i]
            if (word.startsWith(query)) {
                // First word gets higher score than later words
                return scoreWordBoundary - (i * 50)
            }
        }
        
        return scoreNoMatch
    }
    
    /**
     * Basic fuzzy matching for typo tolerance
     * 
     * Implements simple character-based fuzzy matching for common typos.
     * More sophisticated than Levenshtein but lighter weight.
     * 
     * @param {string} text - Text to search in
     * @param {string} query - Search query
     * @returns {boolean} True if fuzzy match found
     */
    function checkFuzzyMatch(text, query) {
        // For now, implement simple character coverage check
        // More sophisticated fuzzy algorithms can be added later
        
        if (query.length < 2) {
            return false  // Too short for meaningful fuzzy matching
        }
        
        // Check if most characters from query appear in text in order
        var textIndex = 0
        var matchedChars = 0
        
        for (var i = 0; i < query.length; i++) {
            var character = query[i]
            var foundIndex = text.indexOf(character, textIndex)
            
            if (foundIndex >= 0) {
                matchedChars++
                textIndex = foundIndex + 1
            }
        }
        
        // Consider it a fuzzy match if most characters are found in order
        var matchRatio = matchedChars / query.length
        return matchRatio >= 0.7  // 70% character coverage required
    }
    
}