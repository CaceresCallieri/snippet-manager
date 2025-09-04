# Remove Hardcoded Absolute Paths

## Priority: P1 (Critical)
## Type: FIX
## Complexity: LOW

## Problem
Hardcoded absolute path in shell.qml creates security and portability issues.

## Vulnerable Code
```javascript
// shell.qml:78
var command = ["/home/jc/Dev/snippet-manager/inject-text.sh", snippet.content]
```

## Issues
- Path only works on specific machine
- Security risk if script location is compromised
- Prevents proper deployment

## Solution
Use relative path resolution:

```javascript
// Get script path relative to shell.qml
const scriptPath = Qt.resolvedUrl("inject-text.sh").toString().replace("file://", "")
var command = [scriptPath, snippet.content]
```

## Impact
- **Before**: Only works on developer machine
- **After**: Portable across systems

## Files to Change
- `/shell.qml` line 78

## Testing
1. Move project to different directory
2. Run from different working directory
3. Verify script still executes correctly