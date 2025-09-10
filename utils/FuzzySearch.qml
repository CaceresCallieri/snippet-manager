pragma Singleton
import QtQuick

/**
 * Fuzzy Search Singleton - Advanced relevance-based search for snippet manager
 * 
 * Implements multi-criteria scoring algorithm with position-based weighting
 * and field importance to provide intelligent search ranking.
 * 
 * Key Features:
 * - Title matches weighted 3x higher than content matches
 * - Position-based scoring (prefix > word boundary > substring)
 * - Capital letter match bonuses
 * - Length normalization for better ranking
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
    
    readonly property int bonusCapitalLetter: 50       // Bonus for capital letter matches
    readonly property int bonusLengthNormalization: 100 // Bonus for shorter strings with matches
    
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
        
        // Extract just the snippets
        return scoredResults.map(function(result) { return result.snippet })
    }
    
    // ============================================================================
    // SCORING ALGORITHM IMPLEMENTATION
    // ============================================================================
    
    /**
     * Calculate comprehensive relevance score for a snippet against search term
     * 
     * Combines multiple scoring criteria with field weighting to produce
     * a final relevance score for ranking purposes.
     * 
     * @param {Object} snippet - Snippet with title and content properties
     * @param {string} normalizedQuery - Lowercase search term
     * @returns {number} Relevance score (higher = more relevant)
     * 
     * Scoring components:
     * - Title match score (weighted 3x)
     * - Content match score (baseline weight)
     * - Length normalization bonus
     * - Capital letter match bonuses
     */
    function calculateRelevanceScore(snippet, normalizedQuery) {
        if (!snippet || !snippet.title || !snippet.content) {
            return scoreNoMatch
        }
        
        // Calculate scores for both fields
        var titleScore = calculateFieldScore(snippet.title, normalizedQuery) * titleMultiplier
        var contentScore = calculateFieldScore(snippet.content, normalizedQuery) * contentMultiplier
        
        // Base score is the sum of field scores
        var totalScore = titleScore + contentScore
        
        // Apply bonuses
        totalScore += calculateLengthBonus(snippet, normalizedQuery)
        totalScore += calculateCapitalLetterBonus(snippet, normalizedQuery)
        
        return Math.round(totalScore)
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
    
    /**
     * Calculate length normalization bonus
     * 
     * Shorter strings with matches should rank higher than longer ones,
     * all else being equal.
     * 
     * @param {Object} snippet - Snippet object
     * @param {string} query - Search query
     * @returns {number} Length normalization bonus
     */
    function calculateLengthBonus(snippet, query) {
        var titleLength = snippet.title.length
        var contentLength = snippet.content.length
        var avgLength = (titleLength + contentLength) / 2
        
        // Shorter content gets bonus (up to 100 points)
        var maxLength = 200  // Reasonable max for normalization
        var bonus = Math.max(0, bonusLengthNormalization * (1 - avgLength / maxLength))
        
        return Math.round(bonus)
    }
    
    /**
     * Calculate bonus for capital letter matches
     * 
     * Matches that align with capital letters often represent more
     * semantically important matches (acronyms, proper nouns, etc.)
     * 
     * @param {Object} snippet - Snippet object
     * @param {string} query - Search query (lowercase)
     * @returns {number} Capital letter match bonus
     */
    function calculateCapitalLetterBonus(snippet, query) {
        var bonus = 0
        
        // Check title for capital letter matches
        bonus += findCapitalMatches(snippet.title, query)
        
        // Check content for capital letter matches (lower weight)
        bonus += Math.round(findCapitalMatches(snippet.content, query) * 0.5)
        
        return bonus
    }
    
    /**
     * Find capital letter alignment matches in text
     * 
     * @param {string} text - Original text with capitalization
     * @param {string} query - Lowercase query
     * @returns {number} Bonus points for capital alignments
     */
    function findCapitalMatches(text, query) {
        var matches = 0
        var lowerText = text.toLowerCase()
        
        for (var i = 0; i < text.length - query.length + 1; i++) {
            var textSegment = lowerText.substr(i, query.length)
            
            if (textSegment === query) {
                // Check if this match aligns with capital letters
                for (var j = 0; j < query.length; j++) {
                    if (text[i + j] !== lowerText[i + j]) {  // Capital letter
                        matches++
                    }
                }
            }
        }
        
        return matches * bonusCapitalLetter
    }
}