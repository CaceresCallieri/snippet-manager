# Path Traversal in JSON Loading

## Priority: P1 (Critical)
## Type: FIX
## Complexity: LOW

## Problem
Relative path for JSON loading can be manipulated if application is launched from different directories.

## Vulnerable Code
```javascript
// shell.qml:45
xhr.open("GET", "data/snippets.json")
```

## Issues
- Could load malicious JSON from different directories
- Fails if launched from wrong working directory
- No control over which file is actually loaded

## Solution
Use absolute path resolution relative to shell.qml location:

```javascript
// Get absolute path to ensure correct file is loaded
const scriptDir = Qt.resolvedUrl(".").toString().replace("file://", "")
const snippetsPath = scriptDir + "/data/snippets.json"
xhr.open("GET", "file://" + snippetsPath)
```

## Impact
- **Before**: Can load wrong/malicious JSON files
- **After**: Always loads correct snippets.json file

## Files to Change
- `/shell.qml` line 45

## Testing
1. Launch app from different directories
2. Try creating malicious data/snippets.json in temp directory
3. Verify only the correct file is loaded