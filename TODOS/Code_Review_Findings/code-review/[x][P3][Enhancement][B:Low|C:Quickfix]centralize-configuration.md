# Centralize Configuration Constants

## Priority: P3 | Type: Enhancement | Benefit: Low | Complexity: Quickfix | ✅ COMPLETED

## Problem Description

The wrapper script contains hardcoded file paths, magic numbers, and timeout values scattered throughout the code. This makes the script difficult to configure for different environments and reduces maintainability when values need to be changed.

## Implementation Plan

1. Create configuration section at top of wrapper script with readonly variables
2. Replace hardcoded paths with centralized constants
3. Replace magic timeout values with named constants
4. Add comments explaining the purpose of each configuration value
5. Ensure all hardcoded values are identified and centralized

## File Locations

- `snippet-manager-wrapper.sh:10-13` - Current configuration section (limited)
- `snippet-manager-wrapper.sh:211` - Hardcoded `/tmp/snippet-manager-result-$$` path
- `snippet-manager-wrapper.sh:349` - Hardcoded `timeout_seconds=30`
- `snippet-manager-wrapper.sh:377` - Hardcoded `sleep 1` delay
- Various locations with hardcoded paths and timeouts

## Success Criteria

- All hardcoded paths moved to configuration section
- All magic numbers replaced with named constants
- Configuration section clearly documented with comments
- Easy to modify timeouts and paths for different environments
- No functional changes to script behavior

## Dependencies

None

## Code Examples

**Current Scattered Configuration:**
```bash
# Hardcoded throughout script
PID_FILE="/tmp/snippet-manager-wrapper.pid"
# ... later in code ...
echo "SUCCESS" > "/tmp/snippet-manager-result-$$"
# ... later in code ...
local timeout_seconds=30
# ... later in code ...
sleep 1
```

**Proposed Centralized Configuration:**
```bash
#!/bin/bash

# Snippet Manager Wrapper Script Configuration
set -euo pipefail

# ============================================================================
# CONFIGURATION SECTION
# ============================================================================

# Directory and file paths
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SNIPPETS_FILE="$SCRIPT_DIR/data/snippets.json"
readonly TEMP_DIR="${TMPDIR:-/tmp}"
readonly PID_FILE="$TEMP_DIR/snippet-manager-wrapper.pid"
readonly RESULT_FILE="$TEMP_DIR/snippet-manager-result-$$"

# Timeout and timing configuration
readonly EVENT_TIMEOUT=30           # Seconds to wait for snippet selection
readonly JSON_TIMEOUT=2             # Seconds to wait for JSON operations
readonly QUICKSHELL_EXIT_DELAY=1    # Seconds to wait after QuickShell exits
readonly SOCKET_CONNECT_DELAY=0.1   # Seconds to wait for socket connection

# Logging configuration
readonly DEBUG_MODE=true

# ============================================================================
# SCRIPT LOGIC
# ============================================================================

# Use centralized constants throughout
echo "SUCCESS" > "$RESULT_FILE"
local timeout_seconds=$EVENT_TIMEOUT
sleep $QUICKSHELL_EXIT_DELAY
```

## Reminder

When implementation is finished, update the filename prefix from `[ ]` to `[x]`.