# Batch JQ Operations for Snippet Lookup

## Priority: P1 | Type: Performance | Benefit: Highest | Complexity: Low

## Problem Description

The `lookup_snippet()` function spawns a separate `jq` process for each individual snippet lookup, creating significant overhead when combining multiple snippets. For a 5-snippet combination, this creates 5 separate `jq` processes and reads the JSON file 5 times, resulting in O(n) process overhead.

## Implementation Plan

1. Create new `lookup_multiple_snippets()` function that processes all titles in a single `jq` call
2. Modify `combine_snippets()` to use batch lookup instead of individual calls
3. Build dynamic jq filter that selects all needed snippets in one pass
4. Join results with newlines directly in jq to eliminate string concatenation

## File Locations

- `snippet-manager-wrapper.sh:78-106` - Current `lookup_snippet()` function
- `snippet-manager-wrapper.sh:108-148` - `combine_snippets()` function that calls lookup repeatedly
- `snippet-manager-wrapper.sh:126` - Loop that calls `lookup_snippet()` multiple times

## Success Criteria

- Single `jq` process spawned for entire combination operation
- JSON file read only once per combination regardless of snippet count
- Performance improvement of 3-5x for combinations of 3+ snippets
- All existing functionality preserved (error handling, logging, validation)
- Backward compatibility with single snippet lookups

## Dependencies

None

## Code Examples

**Current Inefficient Implementation:**
```bash
# In combine_snippets() - called once per snippet
if snippet_content=$(lookup_snippet "$title"); then
    if [ $snippet_count -gt 0 ]; then
        combined_content+=$'\n'
    fi
    combined_content+="$snippet_content"
fi
```

**Proposed Batch Implementation:**
```bash
lookup_multiple_snippets() {
    local titles_string="$1"
    IFS=',' read -ra titles <<< "$titles_string"
    
    # Build jq filter to get all snippets in one pass
    local filter="map(select("
    for i in "${!titles[@]}"; do
        local title=$(echo "${titles[$i]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        filter+=".title == \"$title\""
        if [ $i -lt $((${#titles[@]} - 1)) ]; then
            filter+=" or "
        fi
    done
    filter+=")) | map(.content) | join(\"\n\")"
    
    jq -r "$filter" "$SNIPPETS_FILE" 2>/dev/null
}

combine_snippets() {
    local titles_string="$1"
    
    if combined_content=$(lookup_multiple_snippets "$titles_string"); then
        local snippet_count=$(echo "$titles_string" | tr ',' '\n' | wc -l)
        log "INFO" "✅ Combined ${snippet_count} snippets (total: ${#combined_content} characters)"
        echo "$combined_content"
        return 0
    else
        log "ERROR" "❌ Failed to combine snippets"
        return 1
    fi
}
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.