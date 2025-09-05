# Add Timeout Handling for Process Execution

## Priority: P4 (Low)
## Type: ENHANCEMENT
## Complexity: LOW

## Problem
The text injection process execution has no timeout handling, which could cause the application to hang if the injection script fails or hangs.

## Current Implementation
```javascript
// shell.qml:78-79 - No timeout or error handling
var command = ["/home/jc/Dev/snippet-manager/inject-text.sh", snippet.content]
Quickshell.execDetached(command)
```

## Issues
- No timeout for script execution
- No way to detect if script hangs
- No feedback if injection fails
- No cleanup if script doesn't complete

## Solution
While `Quickshell.execDetached()` runs independently, we should add reasonable safeguards:

```javascript
// Add timeout monitoring (if supported by QuickShell Process)
function executeWithTimeout(command, timeoutMs = 5000) {
    console.log("🚀 Executing injection script with timeout:", timeoutMs + "ms")
    
    try {
        // Execute the detached process
        Quickshell.execDetached(command)
        
        // Log successful execution (we can't actually monitor detached process)
        console.log("✅ Injection script launched successfully")
        
    } catch (error) {
        console.error("❌ Failed to launch injection script:", error)
        
        // Fallback: try alternative injection method or show user notification
        showInjectionError("Failed to launch text injection")
    }
}

function showInjectionError(message) {
    // Could implement user notification here
    console.error("💥 Injection Error:", message)
}
```

## Alternative: Script-Level Timeout
Add timeout handling within the injection script itself:

```bash
#!/bin/bash
# inject-text.sh with timeout handling

text="$1"
timeout_seconds=5

# Validate input length
if [[ ${#text} -gt 10000 ]]; then
    echo "Error: Text too long" >&2
    exit 1
fi

# Allow QuickShell to exit
sleep 0.25

# Use timeout command to limit wtype execution
if command -v timeout >/dev/null 2>&1; then
    timeout ${timeout_seconds} wtype -s 5 "$text"
    exit_code=$?
    
    if [ $exit_code -eq 124 ]; then
        echo "Error: Text injection timed out after ${timeout_seconds} seconds" >&2
        exit 1
    fi
else
    # Fallback without timeout
    wtype -s 5 "$text"
fi
```

## Impact
- **Before**: Potential hangs with no recovery
- **After**: Bounded execution time with graceful failure handling

## Files to Change
- `/shell.qml` - Add timeout handling around execDetached
- `/inject-text.sh` - Add script-level timeout protection

## Testing
1. Test normal injection still works
2. Test with simulated hanging wtype (kill -STOP)
3. Test timeout recovery
4. Verify error messages are helpful