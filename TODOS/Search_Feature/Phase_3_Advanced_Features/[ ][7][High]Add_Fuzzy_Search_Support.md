# Add Fuzzy Search Support

## Context & Background

- **Feature Goal**: Implement intelligent fuzzy search for better snippet discovery with typos and partial matches
- **Current Architecture**: Exact string matching with prefix modes, no tolerance for typos or abbreviations
- **User Story**: Users can find snippets with approximate matches like "func temp" finding "Function Template" or "emal" finding "Email Template"

## Task Description

Implement fuzzy search algorithm that scores snippets based on character sequence matching, substring proximity, and abbreviation patterns. Add configuration toggle between exact and fuzzy search modes, with fuzzy search providing ranked results by relevance score.

## Files to Modify

- **Primary Files**:
    - `/ui/OverlayWindow.qml` (filtering logic) – Replace exact matching with fuzzy algorithm
    - `/utils/Constants.qml` (search constants) – Add fuzzy search configuration
    - `/services/FuzzySearch.qml` (new file) – Dedicated fuzzy search service
- **Supporting Files**: May affect highlighting logic to handle fuzzy matches

## Implementation Details

### Code Changes Required

```qml
// Create new file: /services/FuzzySearch.qml
pragma Singleton
import QtQuick

QtObject {
    // Fuzzy search implementation with scoring
    function fuzzyScore(text, query) {
        if (!query || query.length === 0) return { score: 1, matches: [] }
        if (!text || text.length === 0) return { score: 0, matches: [] }
        
        const textLower = text.toLowerCase()
        const queryLower = query.toLowerCase()
        
        // Exact match gets highest score
        if (textLower.includes(queryLower)) {
            return { score: 0.9, matches: [{ start: textLower.indexOf(queryLower), length: query.length }] }
        }
        
        // Character sequence matching
        let score = 0
        let textIndex = 0
        let matches = []
        
        for (let i = 0; i < queryLower.length; i++) {
            const char = queryLower[i]
            const found = textLower.indexOf(char, textIndex)
            
            if (found === -1) {
                return { score: 0, matches: [] }
            }
            
            // Higher score for consecutive characters
            const gap = found - textIndex
            if (gap === 0 && i > 0) {
                score += 0.1  // Consecutive bonus
            } else {
                score -= gap * 0.01  // Penalty for gaps
            }
            
            matches.push({ start: found, length: 1 })
            textIndex = found + 1
        }
        
        // Normalize score based on text length
        score = Math.max(0, score) / Math.max(text.length, query.length)
        
        return { score, matches }
    }
    
    function searchSnippets(snippets, query, mode = "all") {
        if (!query || query.length === 0) {
            return snippets.map(snippet => ({ snippet, score: 1 }))
        }
        
        const results = []
        
        for (const snippet of snippets) {
            let bestScore = 0
            let bestMatches = []
            
            // Score based on search mode
            if (mode === "all" || mode === "title") {
                const titleResult = fuzzyScore(snippet.title, query)
                if (titleResult.score > bestScore) {
                    bestScore = titleResult.score * 1.2  // Title bonus
                    bestMatches = titleResult.matches
                }
            }
            
            if (mode === "all" || mode === "content") {
                const contentResult = fuzzyScore(snippet.content, query)
                if (contentResult.score > bestScore) {
                    bestScore = contentResult.score
                    bestMatches = contentResult.matches
                }
            }
            
            // Include snippets with score above threshold
            if (bestScore > Constants.search.fuzzyThreshold) {
                results.push({ snippet, score: bestScore, matches: bestMatches })
            }
        }
        
        // Sort by score descending
        return results.sort((a, b) => b.score - a.score)
    }
}
```

```qml
// In Constants.qml - Add fuzzy search settings
readonly property QtObject search: QtObject {
    // ... existing search constants ...
    readonly property bool useFuzzySearch: true
    readonly property real fuzzyThreshold: 0.3
    readonly property int maxFuzzyResults: 10
}
```

```qml
// In OverlayWindow.qml - Update filtering to use fuzzy search
import "../services"

property var filteredSnippets: {
    if (searchMode.term.length === 0) {
        return loadedValidSnippets
    }
    
    if (Constants.search.useFuzzySearch) {
        const fuzzyResults = FuzzySearch.searchSnippets(
            loadedValidSnippets, 
            searchMode.term, 
            searchMode.mode
        )
        return fuzzyResults.slice(0, Constants.search.maxFuzzyResults)
                          .map(result => result.snippet)
    } else {
        // Fallback to exact search
        return loadedValidSnippets.filter(snippet => {
            const searchTerm = searchMode.term.toLowerCase()
            switch (searchMode.mode) {
                case "title": return snippet.title.toLowerCase().includes(searchTerm)
                case "content": return snippet.content.toLowerCase().includes(searchTerm)
                case "all":
                default:
                    return snippet.title.toLowerCase().includes(searchTerm) ||
                           snippet.content.toLowerCase().includes(searchTerm)
            }
        })
    }
}
```

```qml
// Update search input to show fuzzy mode
TextField {
    id: searchInput
    // ... existing properties ...
    
    placeholderText: {
        const fuzzyText = Constants.search.useFuzzySearch ? " (fuzzy)" : ""
        if (searchInput.text.length === 0) {
            return `Search snippets${fuzzyText}... (t: titles, c: content)`
        }
        switch (searchMode.mode) {
            case "title": return `Searching titles${fuzzyText}...`
            case "content": return `Searching content${fuzzyText}...`
            default: return `Search snippets${fuzzyText}...`
        }
    }
}
```

### Integration Points

- FuzzySearch service provides scoring algorithm independent of UI logic
- Integrates with existing search mode detection from Task 6
- Configurable via Constants to allow toggling between exact and fuzzy search
- Results limited and sorted by relevance score

### Architecture Context

- Component Relationships: New FuzzySearch service used by OverlayWindow filtering
- State Management: Fuzzy search maintains no state, pure scoring functions
- Data Flow: snippets + search term → FuzzySearch.searchSnippets → scored results → filtered display

### Dependencies

- Prerequisite Tasks: 
  - Task 6 (Prefix Modes) - requires searchMode.mode and searchMode.term
  - Task 2 (Filtering) - replaces exact filtering logic
- Blocking Tasks: Completes advanced search functionality
- Related Systems: Uses Constants configuration pattern, Services architecture

### Acceptance Criteria

- Fuzzy search finds relevant snippets with typos and partial matches
- Results are ranked by relevance score with most relevant first
- Exact matches still receive high scores and appear at top
- Fuzzy search respects search mode prefixes (title-only, content-only)
- Performance remains acceptable with typical snippet collections
- Configuration allows toggling between exact and fuzzy search
- Fuzzy threshold prevents very low-relevance results from appearing

### Testing Strategy

- Manual Testing:
  - Search with typos and verify relevant results appear
  - Test abbreviation-style searches ("func temp" → "Function Template")
  - Verify exact matches still rank highest
  - Test fuzzy search with different search modes
  - Compare fuzzy vs exact search performance
- Integration Tests: Ensure navigation and highlighting work with fuzzy results
- Edge Cases:
  - Very short search terms with fuzzy matching
  - Search terms with no fuzzy matches
  - Performance with large snippet collections

### Implementation Notes

- Code Patterns: Singleton service pattern for fuzzy search algorithm
- Performance Considerations: Fuzzy scoring is O(n*m) per snippet, may need optimization for large collections
- Future Extensibility: Foundation for advanced scoring (recency, usage frequency, category weighting)

### Commit Information

- Commit Message: "feat: add fuzzy search support with relevance scoring"
- Estimated Time: 2-3 hours
- Complexity Justification: High - Complex algorithm implementation, performance considerations, and integration with existing search infrastructure