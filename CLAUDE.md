# QuickShell Snippet Manager

## Project Overview
A modular snippet manager for Arch Linux Hyprland systems built with QuickShell. Features cursor-positioned overlay access to stored text snippets with direct text injection capabilities.

## Architecture
**Layered Service Architecture** with three distinct layers:
- **Data Persistence Layer**: JSON storage in `~/.config/quickshell/snippet-manager/`
- **Business Logic Layer**: Snippet management, search, variable substitution, text injection
- **Presentation Layer**: Wayland overlay UI, keyboard navigation, user interaction

## Technology Stack
- **Frontend**: QuickShell + QML for Wayland layer overlay
- **Backend**: JavaScript services with Qt integration
- **Storage**: JSON files in user config directory
- **System Integration**: wtype for text injection, hyprctl for cursor positioning

## Development Phases

### Phase 1: Basic Frontend + Static Data ✅ COMPLETED
**Goal**: Create working overlay UI with static snippet list

**Implemented Features**:
- ✅ Overlay window appears immediately on command execution
- ✅ Keyboard navigation (Up/Down arrows, Enter to select)
- ✅ Mouse navigation (hover to select, click to choose)
- ✅ Embedded static snippet data (5 test snippets)
- ✅ Text injection via wtype with proper error handling
- ✅ Auto-exit after selection or dismissal (Escape key)
- ✅ High-visibility UI with orange borders and clear numbering

**Current File Structure**:
```
quickshell-snippet-manager/
├── shell.qml                   # ✅ Main application (ShellRoot + LazyLoader)
├── ui/
│   └── OverlayWindow.qml       # ✅ Simplified overlay with conditional debug logging
├── utils/
│   └── Constants.qml           # ✅ Centralized configuration singleton
├── services/                   # (Legacy - not currently used)
│   ├── DataLoader.qml          # (Replaced by embedded data)
│   ├── TextInjection.qml       # (Replaced by inline Process)
│   └── HyprlandService.qml     # (Simplified in shell.qml)
├── data/
│   └── snippets.json           # ✅ Active JSON data source for snippets
├── inject-text.sh              # ✅ Detached text injection script
└── test_injection.sh           # ✅ Testing utility
```

**Current Implementation Notes**:
- JSON-based data loading from data/snippets.json file
- LazyLoader pattern for memory efficiency
- Direct Process integration for text injection
- Robust UI using Column + Repeater (SnippetList.qml was removed as unused)
- Centralized configuration via Constants.qml singleton
- Auto-quit functionality for launcher-style behavior
- HyprlandFocusGrab for reliable keyboard input capture
- Conditional debug logging system with emoji markers

## Key Requirements

### Overlay Window
- Wayland layer overlay (top-most)
- Positioned at current cursor location
- Exclusive keyboard focus when visible
- Fixed size: 400x300 pixels
- Manual dismiss only (Escape key or selection)

### Keyboard Navigation
- `Escape`: Hide overlay
- `Up Arrow`: Move selection up (wraps to bottom when at top)
- `Down Arrow`: Move selection down (wraps to top when at bottom)
- `Enter`: Select current snippet and inject text

### Global Shortcut
User handles SUPER_L registration via Hyprland configuration.

## Technical Notes

### Dependencies
- QuickShell (Wayland compositor integration)
- wtype (text injection)
- hyprctl (cursor positioning)

### JSON Schema (Current)
```json
[
  {
    "title": "Snippet Title",
    "content": "The actual text content to inject"
  }
]
```

**Note**: The JSON schema was simplified to remove the separate "id" field, using only "title" and "content" properties.

### Integration Points
- Text injection happens after overlay dismissal
- Cursor position obtained via hyprctl
- JSON data loaded from user config directory

## Future Phases
- **Phase 2**: Search functionality, enhanced backend architecture
- **Phase 3**: Variable substitution, preview pane, usage statistics

## Success Criteria for Phase 1
- Overlay appears at cursor within 200ms of activation
- All keyboard navigation works smoothly
- Text injection succeeds for simple text content
- Clean code structure supports easy Phase 2 integration

## Development Resources

### QuickShell Documentation
- **Official Guide**: https://quickshell.org/docs/v0.2.0/guide/
- **Official Examples**: https://git.outfoxxed.me/quickshell/quickshell-examples
- **Advanced Shell Reference**: https://github.com/caelestia-dots/shell

### QuickShell Best Practices
Based on official examples:
- Use `qs -p shell.qml` for command-line testing
- Structure: ShellRoot with LazyLoader for conditional windows
- Use Scope for complex logic organization
- PanelWindow with proper anchoring for overlays
- LazyLoader reduces memory when windows aren't active

### Development Commands
```bash
# Run snippet manager (normal mode) - requires environment variable for JSON loading
QML_XHR_ALLOW_FILE_READ=1 qs -p shell.qml

# Run with verbose QuickShell logging and JSON loading
QML_XHR_ALLOW_FILE_READ=1 qs -p shell.qml --verbose

# Run with debug mode (requires debugMode: true in shell.qml)
QML_XHR_ALLOW_FILE_READ=1 qs -p shell.qml --verbose

# Test text injection directly
wtype "Hello from snippet manager!"
```

**IMPORTANT**: Always test changes by running `QML_XHR_ALLOW_FILE_READ=1 qs -p shell.qml` after making modifications to ensure the application loads correctly and can access the JSON file.

### Debug Mode
Toggle debug logging by changing `debugMode: true/false` in shell.qml:
- **Normal mode**: Clean output, no debug messages
- **Debug mode**: Comprehensive emoji-marked logging for keyboard navigation, focus management, and user interactions

**IMPORTANT**: Always use `window.debugLog()` for debug messages instead of `console.log()`. This ensures conditional logging based on the debug mode setting and maintains consistent emoji-marked debug output throughout the application.

### Hyprland Integration
```bash
# Add to hyprland.conf (recommended)
bind = SUPER SHIFT, SPACE, exec, qs -p /absolute/path/to/snippet-manager/shell.qml
```

### Known Issues & Current Status
- ✅ **QuickShell compatibility**: Fixed with quickshell-git package
- ✅ **UI visibility**: Fixed with high-contrast design and proper Component structure
- ✅ **Process API**: Fixed by removing non-existent `onErrorOccurred` property
- ✅ **Keyboard navigation**: Fixed with HyprlandFocusGrab for reliable input capture
- ✅ **Focus management**: Coordinated focus system eliminates race conditions between Qt and HyprlandFocusGrab
- ✅ **Debug system**: Working conditional logging with emoji markers for development
- ✅ **Text injection**: Fixed with proper `Quickshell.execDetached()` syntax and detached script approach
- ✅ **JSON loading reliability**: Fixed working directory dependency using Qt.resolvedUrl()

### Current Working Features
- ✅ Overlay shows immediately on command execution
- ✅ JSON-based snippet loading from data/snippets.json (10 test snippets)
- ✅ Simplified JSON schema (title + content only, no id field)
- ✅ **Empty state handling** - graceful UI when no snippets available with clear user guidance
- ✅ **Sliding window navigation** - access ALL snippets while displaying only 5
- ✅ **Wrap-around navigation** - infinite scrolling in both directions
- ✅ **Smart header feedback** - shows current position "X of Y snippets"
- ✅ Keyboard navigation (↑/↓ arrows, Enter, Esc) with smooth scrolling
- ✅ Mouse interaction (hover + click)
- ✅ **Text injection via wtype** - working with detached script approach and proper `execDetached()` syntax
- ✅ Auto-exit after selection or dismissal
- ✅ Clean UI with subtitle design (no numbers, clean titles)
- ✅ Debug mode with comprehensive logging system
- ✅ **Performance optimized** - eliminated binding loops in displayedSnippets property
- ✅ **Focus reliability** - coordinated focus management prevents race conditions

### Sliding Window Navigation Implementation
- **windowStart property**: Tracks the first snippet index in the visible window
- **displayedSnippets computed property**: Uses `snippets.slice(windowStart, windowStart + maxDisplayed)`
- **globalIndex property**: Computes absolute position as `windowStart + currentIndex`
- **VS Code-style navigation**: Smooth scrolling that maintains visual continuity
- **Within-window movement**: Arrow keys move cursor locally until boundary reached
- **Boundary scrolling**: At edges, window slides by 1 position while cursor stays at boundary
- **Full range access**: Navigate through all snippets (tested with 8 snippets)
- **Robust edge handling**: Clear feedback at absolute top/bottom boundaries

### Performance Optimization: Binding Loop Fix
**Issue**: The `displayedSnippets` property previously caused QML binding loops due to side effects within the binding.

**Solution**: 
- Made binding pure with `readonly property var displayedSnippets`
- Separated debug tracking to `onDisplayedSnippetsChanged` handler
- Eliminated unnecessary recalculations and callback scheduling

**Technical Implementation**:
```javascript
// Before (caused binding loops)
property var displayedSnippets: {
    Qt.callLater(function() { calculationCount++ })  // Side effect!
    return snippets.slice(windowStart, end)
}

// After (pure binding)  
readonly property var displayedSnippets: {
    if (snippets.length === 0) return []
    const end = Math.min(windowStart + maxDisplayed, snippets.length)
    return snippets.slice(windowStart, end)
}

// Debug tracking handled separately
onDisplayedSnippetsChanged: trackCalculation()
```

**Benefits**:
- Zero binding loop warnings in console output
- Optimal performance - recalculates only when dependencies change
- Maintains all debug tracking functionality
- Follows QML best practices for computed properties

### Focus Management: Race Condition Fix
**Issue**: Multiple simultaneous focus operations caused race conditions between Qt focus system and HyprlandFocusGrab.

**Solution**:
- Coordinated focus management using `HyprlandFocusGrab.onActiveChanged` handler
- Eliminated competing focus operations in Component.onCompleted
- Single, reliable focus establishment pathway

**Benefits**:
- Consistent keyboard input capture on every overlay show
- No focus conflicts between Qt and Hyprland systems  
- Better Wayland integration using native Hyprland focus management
- Cleaner, more maintainable focus code

### Navigation Patterns (8 snippets, 5 displayed):
```
Initial:     Window [0,1,2,3,4] cursor at 0 → Global index 0
Down 4x:     Window [0,1,2,3,4] cursor at 4 → Global index 4
Down 1x:     Window [1,2,3,4,5] cursor at 4 → Global index 5 (scrolled!)
Down 2x:     Window [3,4,5,6,7] cursor at 4 → Global index 7 (end)
Down 1x:     Window [0,1,2,3,4] cursor at 0 → Global index 0 (wrapped!)
Up scroll:   Window [2,3,4,5,6] cursor at 0 → Global index 2 (reverse)
```

### Wrap-Around Navigation Implementation
- **Infinite scrolling**: No dead ends - navigation continues infinitely in both directions
- **Down wrap-around**: From last item (global index 7) → jumps to first item (global index 0)
- **Up wrap-around**: From first item (global index 0) → jumps to last item (global index 7)  
- **Smart positioning**: Wrap-around places window and cursor optimally for continued navigation
- **Seamless UX**: Users can navigate through collections of any size without boundaries
- **Visual continuity**: Window positioning ensures selected item is always clearly visible

### Wrap-Around Logic:
```javascript
// Down arrow at absolute bottom: windowStart = 0, currentIndex = 0
// Up arrow at absolute top: windowStart = max(0, total-maxDisplayed), currentIndex = min(4, total-1)
```

## Text Injection Implementation

### Critical Breakthrough: execDetached Syntax
The key to making text injection work was discovering the correct syntax for `Quickshell.execDetached()`. After extensive debugging, it was found that the function requires both a command array and working directory parameter, similar to `DesktopAction.command`.

**Working Implementation:**
```javascript
onSnippetSelected: function(snippet) {
    console.log("📋 Selected snippet:", snippet.title)
    root.debugLog("🚀 Launching detached script with text argument...")
    
    // CRITICAL: Use command array + working directory (like DesktopAction.command)
    var command = ["/home/jc/Dev/snippet-manager/inject-text.sh", snippet.content]
    Quickshell.execDetached(command, "/home/jc/Dev/snippet-manager")
    
    // Exit immediately
    Qt.quit()
}
```

### Detached Script Architecture
**File**: `inject-text.sh` (Hardened against command injection)
```bash
#!/bin/bash
# Detached text injection script for QuickShell snippet manager
# This script runs independently after QuickShell exits to avoid interference

text="$1"

# Validate input length to prevent resource exhaustion attacks
if [[ ${#text} -gt 10000 ]]; then
    echo "Error: Text too long (max 10KB)" >&2
    exit 1
fi

# Allow QuickShell to exit completely and focus to stabilize
sleep 0.25

# Use printf with stdin for secure text injection (prevents argument parsing exploits)
# -s flag adds milliseconds delay between key events to prevent issues
printf '%s' "$text" | wtype -s 5 -
```

### Security Hardening (P1 Critical Fix)
1. **Input validation**: 10KB length limit prevents resource exhaustion attacks
2. **Safe text handling**: `printf '%s' | wtype -` prevents argument parsing exploits
3. **Command injection prevention**: Stdin approach eliminates shell command execution risks
4. **Defense in depth**: Multiple layers protect against malicious snippet content

### Input Validation System (P1 Critical Security)
Comprehensive validation in `shell.qml` prevents crashes and security issues from malformed snippets:

**Validation Layers**:
1. **Object Structure**: Ensures items are objects, not null/string/number
2. **Required Fields**: Validates presence of `title` and `content` properties
3. **Type Safety**: Enforces string types for both title and content
4. **Content Limits**: 
   - Title: 200 characters maximum
   - Content: 10KB maximum (consistent with inject-text.sh security boundary)

**Graceful Degradation**:
- Invalid snippets filtered out with detailed console warnings
- Valid snippets continue loading normally
- Application never crashes from malformed JSON data
- Users receive clear feedback about validation failures

**Security Benefits**:
- Prevents UI crashes from missing properties (`snippet.title` on undefined objects)
- Blocks memory exhaustion from oversized content
- Ensures consistent security boundaries between QML and shell script layers
- Eliminates type confusion attacks (non-string content causing injection failures)

### Why This Approach Works
1. **Detached execution**: Script runs independently after QuickShell exits
2. **Proper timing**: 0.25s delay allows focus to stabilize
3. **Reliable injection**: wtype with 5ms delays prevents key event issues
4. **Clean architecture**: Separates UI from system interaction
5. **Security first**: Hardened against command injection and DoS attacks

### Technical Notes
- **execDetached documentation**: Found in QuickShell DesktopAction docs showing command array + working directory pattern
- **Hyprland integration**: Works reliably with Hyprland keybind execution
- **Process isolation**: Detached script avoids interference from QuickShell process lifecycle
- **Error handling**: Simple script design minimizes failure points

## Focus Management & Cursor Configuration

### Current Solution: Hyprland Cursor Configuration
The focus switching issue is resolved by configuring Hyprland cursor behavior:

```bash
# Add to hyprland.conf
cursor {
    no_warps = false
}
```

This setting allows the cursor to warp, which maintains proper window focus when the snippet manager overlay appears and disappears.

### Advanced Focus Preservation (Future Enhancement)
For environments where `no_warps = true` is required or for more reliable focus management, implement pre-overlay window capture:

**Problem**: QuickShell overlay interferes with `hyprctl activewindow` queries, returning overlay information instead of the original focused window.

**Solution Strategy**:
1. **Capture window BEFORE showing overlay**: Get active window address in shell.qml before LazyLoader becomes active
2. **Alternative dispatchers**: Test Hyprland's focus dispatchers:
   - `focuscurrentorlast` - Focus current or last focused window
   - `focusurgentorlast` - Focus urgent or last focused window
3. **Timing considerations**: Ensure window capture happens before overlay gains focus

**Implementation Notes**:
- Move `captureFocusedWindow()` call to occur before overlay becomes visible
- Test if alternative dispatchers eliminate need for explicit address tracking
- Consider using Hyprland's window history rather than manual address storage

### Current Status
- ✅ **Simple solution**: `no_warps = false` configuration resolves focus issues
- 🔄 **Advanced solution**: Available for future implementation if needed
- 📋 **Dispatcher testing**: `focuscurrentorlast` and `focusurgentorlast` remain untested but promising

## Path Resolution Fixes
- **JSON loading**: Fixed using `Qt.resolvedUrl("data/snippets.json")` for reliable file access from any directory
- **Script execution**: Fixed using `Qt.resolvedUrl("inject-text.sh")` for portable script path resolution

## Constants Architecture
- **Centralized configuration**: All UI dimensions, timing, and styling values in `/utils/Constants.qml` singleton
- **QML singleton pattern**: Use `import "../utils"` then `Constants.propertyName` for consistent values
- **Shell script integration**: Timing constants documented in comments for bash script reference

## Error Handling & User Notifications

### Desktop Notification Strategy
For critical errors and warnings that users need to be aware of, implement desktop notifications using `notify-send`:

**Implementation Pattern:**
```javascript
// In shell.qml for critical errors
function notifyUser(title, message, urgency = "normal") {
    const command = ["notify-send", "-u", urgency, title, message]
    Quickshell.execDetached(command)
}

// Usage examples:
// notifyUser("Snippet Manager", "No snippets found - check data/snippets.json", "low")
// notifyUser("Snippet Manager Error", "Failed to load snippets file", "critical")
```

**Notification Categories:**
- **Critical**: File system errors, JSON parsing failures, security violations
- **Normal**: Empty snippets, validation warnings, configuration issues  
- **Low**: Informational messages, successful operations

**Benefits:**
- **Non-blocking**: User sees errors even when overlay is dismissed
- **System integration**: Uses standard desktop notification system
- **Severity awareness**: Different urgency levels for different error types
- **Debugging aid**: Helps identify issues in production environments

### Comprehensive Error Handling Implementation

**Process Execution Safety**:
- `validateSnippetData()` function for runtime data validation
- Try-catch blocks around all `Quickshell.execDetached()` calls  
- Desktop notifications for injection failures
- Script path validation before execution

**UI Interaction Safety**:
- `validateAndSelectSnippet()` function for consistent validation
- Mouse click validation before snippet selection
- Bounds checking for hover events and array access
- Prevents crashes from corrupted `modelData`

**Race Condition Prevention**:
- Atomic array snapshots in navigation logic
- Elimination of check-then-use patterns  
- Safe bounds validation with captured snapshots
- Additional empty array checks in navigation

**Error Notification Integration**: All critical errors now trigger desktop notifications with appropriate urgency levels, providing users immediate feedback when operations fail.

## Empty State Handling Implementation

### Dedicated Empty State UI
**Component**: `/ui/EmptyStateView.qml` - Modular component for clean empty state presentation

**Architecture**: Conditional UI rendering based on `hasValidSnippets` property
- Empty state UI shown when `snippets.length === 0`
- Normal snippet list hidden during empty state
- Conditional header and instruction text

**User Experience**:
- Clear "No Snippets Available" message
- Helpful guidance: "Add snippets to data/snippets.json to get started"  
- File location reference for easy access
- Clean, professional appearance without cluttering fake data

**Navigation Safety**: 
- Navigation keys disabled when no valid snippets available
- Escape key always functional regardless of snippet state
- Prevents crashes and undefined behavior with empty arrays
- Debug logging: "🚫 Navigation disabled - no valid snippets available"

**Data Model Integrity**:
- Clean empty array `[]` when no valid snippets (no fake entries)
- Enhanced validation warnings distinguish between empty JSON vs filtered results
- Graceful handling of missing files, parse errors, and validation failures